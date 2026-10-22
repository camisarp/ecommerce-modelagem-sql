USE `ecommerce_refinado`;

START TRANSACTION;

-- 1. Clientes PF
INSERT INTO `Cliente`
    (`idCliente`, `Pnome`, `Nome do meio`, `Sobrenome`,
     `CPF`, `endereço`, `Data de Nascimento`, `TipoCliente`)
VALUES
    (1, 'Ana', NULL, 'Silva',
     '00000000001', 'Rua das Flores, 10', '1995-03-12', 'PF'),
    (2, 'Bruno', NULL, 'Souza',
     '00000000002', 'Rua do Sol, 25', '1990-07-20', 'PF'),
    (3, 'Carla', NULL, 'Lima',
     '00000000003', 'Av. Central, 100', '1998-11-05', 'PF'),
    (4, 'Diego', NULL, 'Santos',
     '00000000004', 'Rua das Palmeiras, 40', '1988-01-15', 'PF');

-- Clientes PJ
INSERT INTO `Cliente`
    (`idCliente`, `TipoCliente`, `CNPJ`, `RazãoSocial`, `endereço`)
VALUES
    (5, 'PJ', '00000000000001',
     'Horizonte Tecnologia LTDA', 'Av. Empresarial, 200'),
    (6, 'PJ', '00000000000002',
     'Papelaria Aprender LTDA', 'Rua Escolar, 80');

-- 2. Produtos
INSERT INTO `Produto`
    (`idProduto`, `Categoria`, `Descrição`, `Valor`)
VALUES
    (1, 'Eletronicos', 'Notebook', 3500.00),
    (2, 'Perifericos', 'Mouse sem fio', 80.00),
    (3, 'Perifericos', 'Teclado mecanico', 200.00),
    (4, 'Eletronicos', 'Monitor 24 polegadas', 900.00),
    (5, 'Moveis', 'Cadeira de escritorio', 700.00),
    (6, 'Papelaria', 'Caderno universitario', 25.00);

-- 3. Fornecedores
INSERT INTO `Fornecedor`
    (`idFornecedor`, `Razão Social`, `CNPJ`, `contato`)
VALUES
    (1, 'Tech Distribuidora LTDA',
     '00000000000101', 'contato@tech.example'),
    (2, 'Moveis Conforto LTDA',
     '00000000000102', 'contato@conforto.example'),
    (3, 'Papel e Cia LTDA',
     '00000000000103', 'contato@papel.example');

-- 4. Produtos fornecidos
INSERT INTO `Produto_fornecedor`
    (`Fornecedor_idFornecedor`, `Produto_idProduto`, `Quantidade`)
VALUES
    (1, 1, 20),
    (1, 2, 100),
    (1, 3, 50),
    (1, 4, 30),
    (2, 5, 40),
    (3, 6, 200);

-- 5. Estoques
-- Quantidade representa o total de unidades no local.
-- O modelo atual não registra saldo individual por produto/local.
INSERT INTO `Estoque`
    (`idEstoque`, `Local`, `Quantidade`)
VALUES
    (1, 'Recife', 200),
    (2, 'Sao Paulo', 240);

-- 6. Localização dos produtos
-- Localização representa o código de uma posição física.
INSERT INTO `Produto_em_Estoque (localização)`
    (`Produto_idProduto`, `Estoque_idEstoque`, `Localização`)
VALUES
    (1, 1, 101),
    (2, 1, 102),
    (3, 1, 103),
    (4, 2, 201),
    (5, 2, 202),
    (6, 1, 104),
    (6, 2, 203);

-- 7. Vendedores
-- O CNPJ do vendedor 1 é igual ao do fornecedor 1.
INSERT INTO `Terceiro - Vendedor`
    (`idTerceiro - Vendedor`, `Razão Social`, `Local`,
     `Nome Fantasia`, `CNPJ`, `CPF`)
VALUES
    (1, 'Tech Distribuidora LTDA', 'Recife',
     'Tech Store', '00000000000101', NULL),
    (2, 'Loja Digital LTDA', 'Sao Paulo',
     'Digital Shop', '00000000000202', NULL),
    (3, 'Marcos Comercio', 'Olinda',
     'Marcos Vendas', NULL, '00000000005');

-- 8. Produtos ofertados pelos vendedores
INSERT INTO `Produtos_vendedor (teceiro)`
    (`idPseller`, `Produto_idProduto`, `Quantidade`)
VALUES
    (1, 1, 10),
    (1, 2, 40),
    (1, 3, 20),
    (2, 4, 15),
    (2, 5, 20),
    (3, 2, 10),
    (3, 6, 50);

-- 9. Formas de pagamento cadastradas
INSERT INTO `FormaPagamento`
    (`idFormaPagamento`, `Tipo`, `Descricao`, `Cliente_idCliente`)
VALUES
    (1, 'Pix', 'Pix de Ana', 1),
    (2, 'Cartao de credito', 'Cartao de Ana', 1),
    (3, 'Boleto', 'Boleto de Bruno', 2),
    (4, 'Pix', 'Pix de Carla', 3),
    (5, 'Cartao de debito', 'Cartao de Diego', 4),
    (6, 'Pix', 'Pix empresarial Horizonte', 5),
    (7, 'Cartao de credito', 'Cartao empresarial Horizonte', 5),
    (8, 'Boleto', 'Boleto empresarial Aprender', 6);

-- 10. Pedidos
-- Diego (cliente 4) está cadastrado, mas não possui pedidos.
INSERT INTO `Pedido`
    (`idPedido`, `Status do pedido`, `descrição`,
     `Cliente_idCliente`, `Frete`)
VALUES
    (1, 'Entregue', 'Notebook e mouse', 1, 30.00),
    (2, 'Enviado', 'Teclado mecanico', 1, 20.00),
    (3, 'Em processando', 'Monitor', 2, 40.00),
    (4, 'Entregue', 'Cadernos universitarios', 3, 10.00),
    (5, 'Enviado', 'Equipamentos para escritorio', 5, 50.00),
    (6, 'Em andamento', 'Cadernos para reposicao', 6, 25.00),
    (7, 'Entregue', 'Cadeira de escritorio', 1, 35.00);

-- 11. Itens dos pedidos
-- No pedido 2, o teclado foi vendido por 180,00.
-- O preço atual no catálogo é 200,00.
INSERT INTO `Produto/pedido`
    (`Produto_idProduto`, `Pedido_idPedido`,
     `Quantidade`, `Status`, `ValorUnitario`)
VALUES
    (1, 1, 1, 'disponível', 3500.00),
    (2, 1, 2, 'disponível', 80.00),
    (3, 2, 1, 'disponível', 180.00),
    (4, 3, 1, 'disponível', 900.00),
    (6, 4, 4, 'disponível', 25.00),
    (4, 5, 2, 'disponível', 900.00),
    (3, 5, 2, 'disponível', 200.00),
    (6, 6, 20, 'disponível', 25.00),
    (5, 7, 1, 'disponível', 700.00);

-- 12. Pagamentos
-- Totais com frete:
-- Pedido 1: 3690,00 | Pedido 2: 200,00
-- Pedido 3: 940,00  | Pedido 4: 110,00
-- Pedido 5: 2250,00 | Pedido 6: 525,00
-- Pedido 7: 735,00
--
-- Pedido 1 foi dividido entre Pix e cartão.
-- Pedido 3 possui tentativa recusada e nova tentativa pendente.
INSERT INTO `Pagamento`
    (`idPagamento`, `Valor`, `Status`, `DataPagamento`,
     `Pedido_idPedido`, `FormaPagamento_idFormaPagamento`,
     `Cliente_idCliente`)
VALUES
    (1, 1000.00, 'Aprovado', '2026-10-01 10:00:00', 1, 1, 1),
    (2, 2690.00, 'Aprovado', '2026-10-01 10:05:00', 1, 2, 1),
    (3, 200.00, 'Aprovado', '2026-10-15 14:30:00', 2, 2, 1),
    (4, 940.00, 'Recusado', NULL, 3, 3, 2),
    (5, 940.00, 'Pendente', NULL, 3, 3, 2),
    (6, 110.00, 'Aprovado', '2026-10-03 09:00:00', 4, 4, 3),
    (7, 2250.00, 'Aprovado', '2026-10-16 11:00:00', 5, 6, 5),
    (8, 525.00, 'Pendente', NULL, 6, 8, 6),
    (9, 735.00, 'Aprovado', '2026-10-05 16:00:00', 7, 1, 1);

-- 13. Entregas
-- Pedido 5 possui duas remessas.
INSERT INTO `Entrega`
    (`idEntrega`, `Status`, `CodigoRastreio`, `Transportadora`,
     `DataEnvio`, `DataEntrega`, `Pedido_idPedido`)
VALUES
    (1, 'Entregue', 'TESTE0001', 'Transportadora Alfa',
     '2026-10-02', '2026-10-06', 1),
    (2, 'Em transporte', 'TESTE0002', 'Transportadora Alfa',
     '2026-10-16', NULL, 2),
    (3, 'Preparando', NULL, NULL,
     NULL, NULL, 3),
    (4, 'Entregue', 'TESTE0004', 'Transportadora Beta',
     '2026-10-04', '2026-10-07', 4),
    (5, 'Entregue', 'TESTE0005A', 'Transportadora Alfa',
     '2026-10-17', '2026-10-20', 5),
    (6, 'Em transporte', 'TESTE0005B', 'Transportadora Beta',
     '2026-10-18', NULL, 5),
    (7, 'Entregue', 'TESTE0007', 'Transportadora Beta',
     '2026-10-06', '2026-10-10', 7);

COMMIT;

-- Conferência: deve retornar 6 clientes, 7 pedidos e 9 pagamentos.
SELECT 'Clientes' AS Tabela, COUNT(*) AS Total FROM `Cliente`
UNION ALL
SELECT 'Pedidos', COUNT(*) FROM `Pedido`
UNION ALL
SELECT 'Pagamentos', COUNT(*) FROM `Pagamento`;