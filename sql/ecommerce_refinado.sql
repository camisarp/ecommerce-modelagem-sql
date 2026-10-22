-- Projeto lógico de e-commerce refinado
-- Criação do esquema e das 13 tabelas
-- MySQL 8.0.16 ou superior

CREATE DATABASE IF NOT EXISTS `ecommerce_refinado`
    DEFAULT CHARACTER SET utf8mb4;

USE `ecommerce_refinado`;

-- 1. Cliente
-- PF: CPF e nome obrigatórios; dados de PJ vazios.
-- PJ: CNPJ e razão social obrigatórios; dados de PF vazios.
-- Os documentos são armazenados sem pontuação.
-- O CHECK verifica preenchimento e tamanho, não dígitos verificadores.

CREATE TABLE IF NOT EXISTS `Cliente` (
    `idCliente` INT NOT NULL AUTO_INCREMENT,
    `Pnome` VARCHAR(10) NULL,
    `Nome do meio` VARCHAR(3) NULL,
    `Sobrenome` VARCHAR(20) NULL,
    `CPF` CHAR(11) NULL,
    `endereço` VARCHAR(45) NULL,
    `Data de Nascimento` DATE NULL,
    `TipoCliente` ENUM('PF', 'PJ') NOT NULL,
    `CNPJ` CHAR(14) NULL,
    `RazãoSocial` VARCHAR(100) NULL,

    PRIMARY KEY (`idCliente`),
    UNIQUE KEY `uq_cliente_cpf` (`CPF`),
    UNIQUE KEY `uq_cliente_cnpj` (`CNPJ`),

    CONSTRAINT `chk_cliente_pf_pj`
    CHECK (
        (
            `TipoCliente` = 'PF'
            AND `CPF` IS NOT NULL
            AND CHAR_LENGTH(TRIM(`CPF`)) = 11
            AND `Pnome` IS NOT NULL
            AND CHAR_LENGTH(TRIM(`Pnome`)) > 0
            AND `CNPJ` IS NULL
            AND `RazãoSocial` IS NULL
        )
        OR
        (
            `TipoCliente` = 'PJ'
            AND `CNPJ` IS NOT NULL
            AND CHAR_LENGTH(TRIM(`CNPJ`)) = 14
            AND `RazãoSocial` IS NOT NULL
            AND CHAR_LENGTH(TRIM(`RazãoSocial`)) > 0
            AND `CPF` IS NULL
            AND `Pnome` IS NULL
            AND `Nome do meio` IS NULL
            AND `Sobrenome` IS NULL
            AND `Data de Nascimento` IS NULL
        )
    )
) ENGINE = InnoDB;

-- 2. Pedido

CREATE TABLE IF NOT EXISTS `Pedido` (
    `idPedido` INT NOT NULL AUTO_INCREMENT,
    `Status do pedido` ENUM(
        'Em andamento',
        'Em processando',
        'Enviado',
        'Entregue'
    ) NULL DEFAULT 'Em processando',
    `descrição` VARCHAR(45) NULL,
    `Cliente_idCliente` INT NOT NULL,
    `Frete` DECIMAL(10,2) NULL DEFAULT NULL,

    PRIMARY KEY (`idPedido`),
    UNIQUE KEY `uq_pedido_cliente`
        (`idPedido`, `Cliente_idCliente`),
    KEY `idx_pedido_cliente` (`Cliente_idCliente`),

    CONSTRAINT `fk_pedido_cliente`
        FOREIGN KEY (`Cliente_idCliente`)
        REFERENCES `Cliente` (`idCliente`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 3. Produto

CREATE TABLE IF NOT EXISTS `Produto` (
    `idProduto` INT NOT NULL AUTO_INCREMENT,
    `Categoria` VARCHAR(45) NOT NULL,
    `Descrição` VARCHAR(45) NULL,
    `Valor` DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (`idProduto`)
) ENGINE = InnoDB;

-- 4. Fornecedor

CREATE TABLE IF NOT EXISTS `Fornecedor` (
    `idFornecedor` INT NOT NULL,
    `Razão Social` VARCHAR(45) NULL,
    `CNPJ` CHAR(14) NOT NULL,
    `contato` VARCHAR(45) NULL,

    PRIMARY KEY (`idFornecedor`),
    UNIQUE KEY `uq_fornecedor_cnpj` (`CNPJ`)
) ENGINE = InnoDB;

-- 5. Produtos por fornecedor

CREATE TABLE IF NOT EXISTS `Produto_fornecedor` (
    `Fornecedor_idFornecedor` INT NOT NULL,
    `Produto_idProduto` INT NOT NULL,
    `Quantidade` INT NULL,

    PRIMARY KEY (`Fornecedor_idFornecedor`, `Produto_idProduto`),
    KEY `idx_produto_fornecedor_produto` (`Produto_idProduto`),

    CONSTRAINT `fk_produto_fornecedor_fornecedor`
        FOREIGN KEY (`Fornecedor_idFornecedor`)
        REFERENCES `Fornecedor` (`idFornecedor`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_produto_fornecedor_produto`
        FOREIGN KEY (`Produto_idProduto`)
        REFERENCES `Produto` (`idProduto`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 6. Estoque

CREATE TABLE IF NOT EXISTS `Estoque` (
    `idEstoque` INT NOT NULL,
    `Local` VARCHAR(45) NOT NULL,
    `Quantidade` INT NOT NULL,

    PRIMARY KEY (`idEstoque`)
) ENGINE = InnoDB;

-- 7. Localização dos produtos nos estoques

CREATE TABLE IF NOT EXISTS `Produto_em_Estoque (localização)` (
    `Produto_idProduto` INT NOT NULL,
    `Estoque_idEstoque` INT NOT NULL,
    `Localização` INT NULL,

    PRIMARY KEY (`Produto_idProduto`, `Estoque_idEstoque`),
    KEY `idx_produto_estoque_estoque` (`Estoque_idEstoque`),

    CONSTRAINT `fk_produto_estoque_produto`
        FOREIGN KEY (`Produto_idProduto`)
        REFERENCES `Produto` (`idProduto`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_produto_estoque_estoque`
        FOREIGN KEY (`Estoque_idEstoque`)
        REFERENCES `Estoque` (`idEstoque`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 8. Itens do pedido
-- ValorUnitario registra o preço praticado na venda.

CREATE TABLE IF NOT EXISTS `Produto/pedido` (
    `Produto_idProduto` INT NOT NULL,
    `Pedido_idPedido` INT NOT NULL,
    `Quantidade` INT NOT NULL,
    `Status` ENUM(
        'disponível',
        'sem estoque'
    ) NULL DEFAULT 'disponível',
    `ValorUnitario` DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (`Produto_idProduto`, `Pedido_idPedido`),
    KEY `idx_item_pedido` (`Pedido_idPedido`),

    CONSTRAINT `fk_item_produto`
        FOREIGN KEY (`Produto_idProduto`)
        REFERENCES `Produto` (`idProduto`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_item_pedido`
        FOREIGN KEY (`Pedido_idPedido`)
        REFERENCES `Pedido` (`idPedido`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 9. Vendedor terceiro

CREATE TABLE IF NOT EXISTS `Terceiro - Vendedor` (
    `idTerceiro - Vendedor` INT NOT NULL AUTO_INCREMENT,
    `Razão Social` VARCHAR(45) NOT NULL,
    `Local` VARCHAR(45) NULL,
    `Nome Fantasia` VARCHAR(45) NULL,
    `CNPJ` CHAR(14) NULL,
    `CPF` CHAR(11) NULL,

    PRIMARY KEY (`idTerceiro - Vendedor`),
    UNIQUE KEY `uq_vendedor_razao_social` (`Razão Social`),
    UNIQUE KEY `uq_vendedor_cnpj` (`CNPJ`),
    UNIQUE KEY `uq_vendedor_cpf` (`CPF`)
) ENGINE = InnoDB;

-- 10. Produtos por vendedor
-- idPseller referencia um vendedor existente: não usa AUTO_INCREMENT.
-- Nome da tabela preservado conforme o modelo.

CREATE TABLE IF NOT EXISTS `Produtos_vendedor (teceiro)` (
    `idPseller` INT NOT NULL,
    `Produto_idProduto` INT NOT NULL,
    `Quantidade` INT NULL,

    PRIMARY KEY (`idPseller`, `Produto_idProduto`),
    KEY `idx_produtos_vendedor_produto` (`Produto_idProduto`),

    CONSTRAINT `fk_produtos_vendedor_vendedor`
        FOREIGN KEY (`idPseller`)
        REFERENCES `Terceiro - Vendedor` (`idTerceiro - Vendedor`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_produtos_vendedor_produto`
        FOREIGN KEY (`Produto_idProduto`)
        REFERENCES `Produto` (`idProduto`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 11. Formas de pagamento cadastradas por cliente
-- Um cliente pode cadastrar várias formas.

CREATE TABLE IF NOT EXISTS `FormaPagamento` (
    `idFormaPagamento` INT NOT NULL AUTO_INCREMENT,
    `Tipo` ENUM(
        'Pix',
        'Boleto',
        'Cartao de credito',
        'Cartao de debito'
    ) NOT NULL,
    `Descricao` VARCHAR(100) NULL,
    `Cliente_idCliente` INT NOT NULL,

    PRIMARY KEY (`idFormaPagamento`),
    UNIQUE KEY `uq_forma_cliente`
        (`idFormaPagamento`, `Cliente_idCliente`),
    KEY `idx_forma_cliente` (`Cliente_idCliente`),

    CONSTRAINT `fk_forma_cliente`
        FOREIGN KEY (`Cliente_idCliente`)
        REFERENCES `Cliente` (`idCliente`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 12. Entrega
-- Um pedido pode possuir várias entregas.
-- Rastreio e datas podem ficar vazios durante a preparação.

CREATE TABLE IF NOT EXISTS `Entrega` (
    `idEntrega` INT NOT NULL AUTO_INCREMENT,
    `Status` ENUM(
        'Preparando',
        'Enviado',
        'Em transporte',
        'Entregue',
        'Cancelado'
    ) NOT NULL,
    `CodigoRastreio` VARCHAR(50) NULL,
    `Transportadora` VARCHAR(100) NULL,
    `DataEnvio` DATE NULL,
    `DataEntrega` DATE NULL,
    `Pedido_idPedido` INT NOT NULL,

    PRIMARY KEY (`idEntrega`),
    UNIQUE KEY `uq_entrega_rastreio` (`CodigoRastreio`),
    KEY `idx_entrega_pedido` (`Pedido_idPedido`),

    CONSTRAINT `fk_entrega_pedido`
        FOREIGN KEY (`Pedido_idPedido`)
        REFERENCES `Pedido` (`idPedido`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- 13. Pagamento
-- As duas chaves compostas compartilham Cliente_idCliente.
-- Isso impede usar a forma de pagamento de outro cliente.
-- Um pedido pode possuir vários registros de pagamento.

CREATE TABLE IF NOT EXISTS `Pagamento` (
    `idPagamento` INT NOT NULL AUTO_INCREMENT,
    `Valor` DECIMAL(10,2) NOT NULL,
    `Status` ENUM(
        'Pendente',
        'Aprovado',
        'Recusado',
        'Estornado'
    ) NOT NULL,
    `DataPagamento` DATETIME NULL,
    `Pedido_idPedido` INT NOT NULL,
    `FormaPagamento_idFormaPagamento` INT NOT NULL,
    `Cliente_idCliente` INT NOT NULL,

    PRIMARY KEY (`idPagamento`),
    KEY `idx_pagamento_pedido_cliente`
        (`Pedido_idPedido`, `Cliente_idCliente`),
    KEY `idx_pagamento_forma_cliente`
        (`FormaPagamento_idFormaPagamento`, `Cliente_idCliente`),

    CONSTRAINT `fk_pagamento_pedido_cliente`
        FOREIGN KEY (`Pedido_idPedido`, `Cliente_idCliente`)
        REFERENCES `Pedido` (`idPedido`, `Cliente_idCliente`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_pagamento_forma_cliente`
        FOREIGN KEY (
            `FormaPagamento_idFormaPagamento`,
            `Cliente_idCliente`
        )
        REFERENCES `FormaPagamento` (
            `idFormaPagamento`,
            `Cliente_idCliente`
        )
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Conferência das tabelas criadas
SHOW TABLES;