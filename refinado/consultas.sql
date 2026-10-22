USE `ecommerce_refinado`;

-- 1. Quais produtos estão cadastrados?
-- SELECT simples.
SELECT
    `idProduto`,
    `Descrição`,
    `Categoria`,
    `Valor`
FROM `Produto`;


-- 2. Quais produtos custam pelo menos R$ 200?
-- WHERE e ORDER BY.
SELECT
    `Descrição`,
    `Categoria`,
    `Valor`
FROM `Produto`
WHERE `Valor` >= 200.00
ORDER BY `Valor` DESC, `idProduto`;


-- 3. Quem são os clientes e qual o tipo de cada conta?
-- CASE para apresentar nomes de PF e PJ na mesma coluna.
SELECT
    `idCliente`,
    `TipoCliente`,
    CASE
        WHEN `TipoCliente` = 'PF'
        THEN CONCAT_WS(' ', `Pnome`, `Nome do meio`, `Sobrenome`)
        ELSE `RazãoSocial`
    END AS NomeCliente,
    CASE
        WHEN `TipoCliente` = 'PF' THEN `CPF`
        ELSE `CNPJ`
    END AS Documento
FROM `Cliente`
ORDER BY NomeCliente;


-- 4. Quantos pedidos cada cliente fez, incluindo quem não comprou?
-- LEFT JOIN, COUNT e GROUP BY.
SELECT
    c.`idCliente`,
    CASE
        WHEN c.`TipoCliente` = 'PF'
        THEN CONCAT_WS(' ', c.`Pnome`, c.`Nome do meio`, c.`Sobrenome`)
        ELSE c.`RazãoSocial`
    END AS NomeCliente,
    COUNT(p.`idPedido`) AS QuantidadePedidos
FROM `Cliente` AS c
LEFT JOIN `Pedido` AS p
    ON p.`Cliente_idCliente` = c.`idCliente`
GROUP BY
    c.`idCliente`,
    c.`TipoCliente`,
    c.`Pnome`,
    c.`Nome do meio`,
    c.`Sobrenome`,
    c.`RazãoSocial`
ORDER BY QuantidadePedidos DESC, c.`idCliente`;


-- 5. Quais clientes fizeram mais de um pedido?
-- HAVING filtra o resultado dos grupos.
SELECT
    c.`idCliente`,
    CASE
        WHEN c.`TipoCliente` = 'PF'
        THEN CONCAT_WS(' ', c.`Pnome`, c.`Nome do meio`, c.`Sobrenome`)
        ELSE c.`RazãoSocial`
    END AS NomeCliente,
    COUNT(p.`idPedido`) AS QuantidadePedidos
FROM `Cliente` AS c
JOIN `Pedido` AS p
    ON p.`Cliente_idCliente` = c.`idCliente`
GROUP BY
    c.`idCliente`,
    c.`TipoCliente`,
    c.`Pnome`,
    c.`Nome do meio`,
    c.`Sobrenome`,
    c.`RazãoSocial`
HAVING COUNT(p.`idPedido`) > 1
ORDER BY QuantidadePedidos DESC, c.`idCliente`;


-- 6. Qual o subtotal de cada item vendido?
-- Atributo derivado: quantidade multiplicada pelo preço da venda.
SELECT
    i.`Pedido_idPedido` AS Pedido,
    pr.`Descrição` AS Produto,
    i.`Quantidade`,
    i.`ValorUnitario`,
    i.`Quantidade` * i.`ValorUnitario` AS SubtotalItem
FROM `Produto/pedido` AS i
JOIN `Produto` AS pr
    ON pr.`idProduto` = i.`Produto_idProduto`
ORDER BY i.`Pedido_idPedido`, pr.`idProduto`;


-- 7. Qual o valor total de cada pedido, incluindo o frete?
-- O frete é somado uma única vez por pedido.
SELECT
    p.`idPedido`,
    p.`Status do pedido`,
    SUM(i.`Quantidade` * i.`ValorUnitario`) AS TotalProdutos,
    COALESCE(p.`Frete`, 0.00) AS Frete,
    SUM(i.`Quantidade` * i.`ValorUnitario`)
        + COALESCE(p.`Frete`, 0.00) AS TotalPedido
FROM `Pedido` AS p
JOIN `Produto/pedido` AS i
    ON i.`Pedido_idPedido` = p.`idPedido`
GROUP BY
    p.`idPedido`,
    p.`Status do pedido`,
    p.`Frete`
ORDER BY TotalPedido DESC, p.`idPedido`;


-- 8. Quais pedidos têm total superior a R$ 1.000?
-- HAVING com uma expressão agregada.
SELECT
    p.`idPedido`,
    SUM(i.`Quantidade` * i.`ValorUnitario`)
        + COALESCE(p.`Frete`, 0.00) AS TotalPedido
FROM `Pedido` AS p
JOIN `Produto/pedido` AS i
    ON i.`Pedido_idPedido` = p.`idPedido`
GROUP BY p.`idPedido`, p.`Frete`
HAVING SUM(i.`Quantidade` * i.`ValorUnitario`)
    + COALESCE(p.`Frete`, 0.00) > 1000.00
ORDER BY TotalPedido DESC, p.`idPedido`;


-- 9. Algum vendedor também é fornecedor?
-- Comparação pelo CNPJ, sem depender de nomes iguais.
SELECT
    v.`idTerceiro - Vendedor` AS IdVendedor,
    v.`Razão Social` AS Vendedor,
    f.`idFornecedor`,
    f.`Razão Social` AS Fornecedor,
    v.`CNPJ`
FROM `Terceiro - Vendedor` AS v
JOIN `Fornecedor` AS f
    ON f.`CNPJ` = v.`CNPJ`
ORDER BY Vendedor;


-- 10. Quais produtos cada fornecedor fornece?
SELECT
    f.`Razão Social` AS Fornecedor,
    pr.`Descrição` AS Produto,
    pf.`Quantidade` AS QuantidadeFornecida
FROM `Produto_fornecedor` AS pf
JOIN `Fornecedor` AS f
    ON f.`idFornecedor` = pf.`Fornecedor_idFornecedor`
JOIN `Produto` AS pr
    ON pr.`idProduto` = pf.`Produto_idProduto`
ORDER BY Fornecedor, Produto;


-- 11. Qual a relação entre produtos, fornecedores e estoques?
-- Cada linha representa uma combinação fornecedor/produto/local.
-- O modelo não possui saldo individual de produto por estoque.
SELECT
    pr.`Descrição` AS Produto,
    f.`Razão Social` AS Fornecedor,
    e.`Local` AS Estoque,
    pe.`Localização` AS PosicaoFisica
FROM `Produto` AS pr
JOIN `Produto_fornecedor` AS pf
    ON pf.`Produto_idProduto` = pr.`idProduto`
JOIN `Fornecedor` AS f
    ON f.`idFornecedor` = pf.`Fornecedor_idFornecedor`
JOIN `Produto_em_Estoque (localização)` AS pe
    ON pe.`Produto_idProduto` = pr.`idProduto`
JOIN `Estoque` AS e
    ON e.`idEstoque` = pe.`Estoque_idEstoque`
ORDER BY Produto, Fornecedor, Estoque;


-- 12. Quais clientes possuem várias formas de pagamento?
SELECT
    c.`idCliente`,
    CASE
        WHEN c.`TipoCliente` = 'PF'
        THEN CONCAT_WS(' ', c.`Pnome`, c.`Nome do meio`, c.`Sobrenome`)
        ELSE c.`RazãoSocial`
    END AS NomeCliente,
    COUNT(fp.`idFormaPagamento`) AS FormasCadastradas
FROM `Cliente` AS c
JOIN `FormaPagamento` AS fp
    ON fp.`Cliente_idCliente` = c.`idCliente`
GROUP BY
    c.`idCliente`,
    c.`TipoCliente`,
    c.`Pnome`,
    c.`Nome do meio`,
    c.`Sobrenome`,
    c.`RazãoSocial`
HAVING COUNT(fp.`idFormaPagamento`) > 1
ORDER BY FormasCadastradas DESC, c.`idCliente`;


-- 13. Quanto foi aprovado em pagamentos por tipo?
-- Tentativas recusadas e pendentes não entram no total recebido.
SELECT
    fp.`Tipo`,
    COUNT(*) AS PagamentosAprovados,
    SUM(pg.`Valor`) AS TotalAprovado
FROM `Pagamento` AS pg
JOIN `FormaPagamento` AS fp
    ON fp.`idFormaPagamento` = pg.`FormaPagamento_idFormaPagamento`
WHERE pg.`Status` = 'Aprovado'
GROUP BY fp.`Tipo`
ORDER BY TotalAprovado DESC, fp.`Tipo`;


-- 14. Quais pedidos ainda possuem saldo a pagar?
-- Agrega itens e pagamentos separadamente para evitar duplicações.
WITH TotaisPedidos AS (
    SELECT
        p.`idPedido`,
        SUM(i.`Quantidade` * i.`ValorUnitario`)
            + COALESCE(p.`Frete`, 0.00) AS TotalPedido
    FROM `Pedido` AS p
    JOIN `Produto/pedido` AS i
        ON i.`Pedido_idPedido` = p.`idPedido`
    GROUP BY p.`idPedido`, p.`Frete`
),
TotaisPagos AS (
    SELECT
        `Pedido_idPedido`,
        SUM(`Valor`) AS TotalAprovado
    FROM `Pagamento`
    WHERE `Status` = 'Aprovado'
    GROUP BY `Pedido_idPedido`
)
SELECT
    t.`idPedido`,
    t.TotalPedido,
    COALESCE(pg.TotalAprovado, 0.00) AS TotalAprovado,
    t.TotalPedido - COALESCE(pg.TotalAprovado, 0.00) AS SaldoPendente
FROM TotaisPedidos AS t
LEFT JOIN TotaisPagos AS pg
    ON pg.`Pedido_idPedido` = t.`idPedido`
WHERE t.TotalPedido > COALESCE(pg.TotalAprovado, 0.00)
ORDER BY SaldoPendente DESC, t.`idPedido`;


-- 15. Quais entregas estão em transporte e qual o rastreio?
SELECT
    `idEntrega`,
    `Pedido_idPedido` AS Pedido,
    `Transportadora`,
    `CodigoRastreio`,
    `DataEnvio`
FROM `Entrega`
WHERE `Status` = 'Em transporte'
ORDER BY `DataEnvio`, `idEntrega`;


-- 16. Quantos dias cada entrega concluída levou?
-- Atributo derivado com DATEDIFF.
SELECT
    `idEntrega`,
    `Pedido_idPedido` AS Pedido,
    `Transportadora`,
    `DataEnvio`,
    `DataEntrega`,
    DATEDIFF(`DataEntrega`, `DataEnvio`) AS DiasEmTransporte
FROM `Entrega`
WHERE `Status` = 'Entregue'
    AND `DataEnvio` IS NOT NULL
    AND `DataEntrega` IS NOT NULL
ORDER BY DiasEmTransporte DESC, `idEntrega`;


-- 17. Quais produtos tiveram mais unidades pedidas?
-- Inclui pedidos ainda não pagos: não representa receita recebida.
SELECT
    pr.`idProduto`,
    pr.`Descrição` AS Produto,
    SUM(i.`Quantidade`) AS UnidadesPedidas,
    SUM(i.`Quantidade` * i.`ValorUnitario`) AS ValorDosItens
FROM `Produto` AS pr
JOIN `Produto/pedido` AS i
    ON i.`Produto_idProduto` = pr.`idProduto`
GROUP BY pr.`idProduto`, pr.`Descrição`
ORDER BY UnidadesPedidas DESC, pr.`idProduto`;


-- 18. Em quais itens o preço da venda difere do preço atual?
SELECT
    i.`Pedido_idPedido` AS Pedido,
    pr.`Descrição` AS Produto,
    pr.`Valor` AS PrecoAtual,
    i.`ValorUnitario` AS PrecoNaVenda,
    pr.`Valor` - i.`ValorUnitario` AS DiferencaPorUnidade
FROM `Produto/pedido` AS i
JOIN `Produto` AS pr
    ON pr.`idProduto` = i.`Produto_idProduto`
WHERE i.`ValorUnitario` <> pr.`Valor`
ORDER BY Pedido, pr.`idProduto`;