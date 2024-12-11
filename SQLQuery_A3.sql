-- Criação de tabelas e índice

CREATE DATABASE A3;

CREATE TABLE Conta (
    ContaID INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL,
    SaldoInicial DECIMAL(18, 2) DEFAULT 0.00,
    DataCriacao DATE NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Categoria (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL,
    Tipo CHAR(1) CHECK (Tipo IN ('R', 'D', 'I'))
);

CREATE TABLE CentroCusto (
    CentroCustoID INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE FormaPagamento (
    FormaPagamentoID INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(100) NOT NULL
);

CREATE TABLE MovimentacaoFinanceira (
    MovimentacaoID INT PRIMARY KEY IDENTITY(1,1),
    ContaID INT,
    CategoriaID INT,
    CentroCustoID INT,
    FormaPagamentoID INT,
    Valor DECIMAL(18, 2) NOT NULL,
    DataMovimentacao DATE NOT NULL,
    Descricao VARCHAR(255),
    FOREIGN KEY (ContaID) REFERENCES Conta(ContaID),
    FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID),
    FOREIGN KEY (CentroCustoID) REFERENCES CentroCusto(CentroCustoID),
    FOREIGN KEY (FormaPagamentoID) REFERENCES FormaPagamento(FormaPagamentoID)
);

CREATE INDEX IDX_MovimentacaoFinanceira_ContaID ON MovimentacaoFinanceira(ContaID);
CREATE INDEX IDX_MovimentacaoFinanceira_CategoriaID ON MovimentacaoFinanceira(CategoriaID);
CREATE INDEX IDX_MovimentacaoFinanceira_CentroCustoID ON MovimentacaoFinanceira(CentroCustoID);
CREATE INDEX IDX_MovimentacaoFinanceira_FormaPagamentoID ON MovimentacaoFinanceira(FormaPagamentoID);
CREATE INDEX IDX_MovimentacaoFinanceira_DataMovimentacao ON MovimentacaoFinanceira(DataMovimentacao);

CREATE INDEX IDX_MovimentacaoFinanceira_Valor_Data ON MovimentacaoFinanceira(Valor, DataMovimentacao);

CREATE INDEX IDX_Conta_Nome ON Conta(Nome);
CREATE INDEX IDX_Categoria_Nome ON Categoria(Nome);
CREATE INDEX IDX_CentroCusto_Nome ON CentroCusto(Nome);
CREATE INDEX IDX_FormaPagamento_Descricao ON FormaPagamento(Descricao);

-- Popular tabela

SELECT * FROM Conta;

INSERT INTO Conta (Nome, SaldoInicial, DataCriacao) VALUES ('Julia', 600, '2024/12/10');
INSERT INTO Conta (Nome, SaldoInicial, DataCriacao) VALUES ('Maria', 800, '2024/12/09');
INSERT INTO Conta (Nome, SaldoInicial, DataCriacao) VALUES ('Jose', 1000, '2024/12/13');
INSERT INTO Conta (Nome, SaldoInicial, DataCriacao) VALUES ('Luis', 400, '2024/12/08');
INSERT INTO Conta (Nome, SaldoInicial, DataCriacao) VALUES ('Luisa', 1400, '2024/12/15');

SELECT * FROM Categoria;

INSERT INTO Categoria (Nome, Tipo) VALUES ('Compras', 'D');
INSERT INTO Categoria (Nome, Tipo) VALUES ('Salario', 'R');
INSERT INTO Categoria (Nome, Tipo) VALUES ('Poupanca', 'I');
INSERT INTO Categoria (Nome, Tipo) VALUES ('Farmacia', 'D');
INSERT INTO Categoria (Nome, Tipo) VALUES ('BolsadeValores', 'I');

SELECT * FROM CentroCusto;

INSERT INTO CentroCusto (Nome) VALUES ('Lazer');
INSERT INTO CentroCusto (Nome) VALUES ('Educacao');
INSERT INTO CentroCusto (Nome) VALUES ('Investimento');
INSERT INTO CentroCusto (Nome) VALUES ('Saude');
INSERT INTO CentroCusto (Nome) VALUES ('Divida');

SELECT * FROM FormaPagamento;

INSERT INTO FormaPagamento (Descricao) VALUES ('PIX');
INSERT INTO FormaPagamento (Descricao) VALUES ('Transferencia');
INSERT INTO FormaPagamento (Descricao) VALUES ('TED');
INSERT INTO FormaPagamento (Descricao) VALUES ('Boleto');
INSERT INTO FormaPagamento (Descricao) VALUES ('Cartao');

SELECT * FROM MovimentacaoFinanceira;

INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao) VALUES (1, 1, 1, 1, 80, '2024/12/12', 'D');
INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao) VALUES (2, 2, 2, 2, 100, '2024/12/10', 'I');
INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao) VALUES (3, 3, 3, 3, 180, '2024/12/17', 'R');
INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao) VALUES (4, 4, 4, 4, 20, '2024/12/10', 'D');
INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao) VALUES (5, 5, 5, 5, 400, '2024/12/16', 'I');

--SELECT 
--    i.name AS IndexName,
--    t.name AS TableName,
--    c.name AS ColumnName,
--    i.type_desc AS IndexType,
--    i.is_unique AS IsUnique
--FROM 
--    sys.indexes i
--JOIN 
--    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
--JOIN 
--    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--JOIN 
--    sys.tables t ON i.object_id = t.object_id
--WHERE 
--    t.is_ms_shipped = 0
--ORDER BY 
--    t.name, i.name, ic.key_ordinal;


-- Criação de Procedure

CREATE PROCEDURE CalcularSaldoFluxoCaixa
    @ContaID INT
AS
BEGIN
    DECLARE @SaldoInicial DECIMAL(18, 2);
    DECLARE @Movimentacoes DECIMAL(18, 2);

    -- Obtém o saldo inicial da conta
    SELECT @SaldoInicial = SaldoInicial FROM Conta WHERE ContaID = @ContaID;

    -- Calcula o total de movimentações (receitas - despesas) da conta
    SELECT @Movimentacoes = SUM(CASE WHEN c.Tipo = 'R' THEN Valor ELSE -Valor END)
    FROM MovimentacaoFinanceira mf
    JOIN Categoria c ON mf.CategoriaID = c.CategoriaID
    WHERE mf.ContaID = @ContaID;

    -- Exibe o saldo atual
    SELECT (@SaldoInicial + ISNULL(@Movimentacoes, 0)) AS SaldoAtual;
END;

	--- Comando para executar
	EXEC CalcularSaldoFluxoCaixa @ContaID = 1;
	 
CREATE PROCEDURE RelatorioReceitasDespesas
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SELECT 
        mf.DataMovimentacao,
        c.Nome AS Categoria,
        cc.Nome AS CentroCusto,
        fp.Descricao AS FormaPagamento,
        mf.Valor,
        CASE 
            WHEN c.Tipo = 'R' THEN 'Receita'
            WHEN c.Tipo = 'D' THEN 'Despesa'
            ELSE 'Indefinido'
        END AS TipoMovimentacao
    FROM MovimentacaoFinanceira mf
    JOIN Categoria c ON mf.CategoriaID = c.CategoriaID
    JOIN CentroCusto cc ON mf.CentroCustoID = cc.CentroCustoID
    JOIN FormaPagamento fp ON mf.FormaPagamentoID = fp.FormaPagamentoID
    WHERE mf.DataMovimentacao BETWEEN @DataInicio AND @DataFim
    ORDER BY mf.DataMovimentacao;
END;

	-- Gerar relatório (geral)
	EXEC RelatorioReceitasDespesas @DataInicio = '2024-12-01', @DataFim = '2024-12-31';

CREATE PROCEDURE ProjecaoFluxoCaixa
    @ContaID INT,
    @DiasProjecao INT
AS
BEGIN
    DECLARE @MediaMovimentacoes DECIMAL(18, 2);

    -- Calcula a média de movimentações diárias para a conta
    SELECT @MediaMovimentacoes = AVG(CASE WHEN c.Tipo = 'R' THEN Valor ELSE -Valor END)
    FROM MovimentacaoFinanceira mf
    JOIN Categoria c ON mf.CategoriaID = c.CategoriaID
    WHERE mf.ContaID = @ContaID;
    
    -- Projeta o fluxo de caixa
    DECLARE @Projecao DECIMAL(18, 2);
    SET @Projecao = @MediaMovimentacoes * @DiasProjecao;

    -- Exibe a projeção do fluxo de caixa futuro
    SELECT @Projecao AS ProjecaoFluxoCaixa;
END;

	--Projeção do fluxo de caixa futuro
	EXEC ProjecaoFluxoCaixa @ContaID = 1, @DiasProjecao = 30;

	DROP PROCEDURE ValidarEntrada;

CREATE PROCEDURE ValidarEntrada
    @ContaID INT,
    @CategoriaID INT,
    @CentroCustoID INT,
    @FormaPagamentoID INT,
    @Valor DECIMAL(18, 2),
    @DataMovimentacao DATE,
    @Descricao VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Conta WHERE ContaID = @ContaID)
    BEGIN
        PRINT 'Conta não encontrada.';
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM Categoria WHERE CategoriaID = @CategoriaID)
    BEGIN
        PRINT 'Categoria não encontrada.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM CentroCusto WHERE CentroCustoID = @CentroCustoID)
    BEGIN
        PRINT 'Centro de custo não encontrado.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM FormaPagamento WHERE FormaPagamentoID = @FormaPagamentoID)
    BEGIN
        PRINT 'Forma de pagamento não encontrada.';
        RETURN;
    END

	    IF @Descricao NOT IN ('D', 'R', 'I')
    BEGIN
        PRINT 'Descrição inválida. Deve ser D, R, ou I.';
        RETURN;
	END

    -- Se todas as validações passarem, insere a movimentação
    INSERT INTO MovimentacaoFinanceira (ContaID, CategoriaID, CentroCustoID, FormaPagamentoID, Valor, DataMovimentacao, Descricao)
    VALUES (@ContaID, @CategoriaID, @CentroCustoID, @FormaPagamentoID, @Valor, @DataMovimentacao, @Descricao);

    PRINT 'Movimentação inserida com sucesso.';
END;	

--Validação de dados de entrada
EXEC ValidarEntrada 
     @ContaID = 1, 
     @CategoriaID = 1, 
     @CentroCustoID = 1, 
     @FormaPagamentoID = 1, 
     @Valor = 100.00, 
     @DataMovimentacao = '2024-12-20', 
     @Descricao = 'D';

	 UPDATE MovimentacaoFinanceira
	 SET Descricao = 'D'
	 WHERE MovimentacaoID = 6;

	 --SELECT * FROM MovimentacaoFinanceira WHERE ContaID = 1;

-- Criação de Funções

CREATE FUNCTION CalcularJurosCompostos
(
    @Principal DECIMAL(18, 2), -- Capital inicial
    @TaxaJuros FLOAT,          -- Taxa de juros por período
    @NumeroPeriodos INT        -- Número de períodos
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Montante DECIMAL(18, 2);
    SET @Montante = @Principal * POWER(1 + @TaxaJuros, @NumeroPeriodos);
    RETURN @Montante;
END;
 
-- cálculo juros compostos
SELECT dbo.CalcularJurosCompostos(1000.00, 0.05, 10) AS Montante;

CREATE FUNCTION CalcularVPLGeral (
       @TaxaDesconto DECIMAL(10, 5)
   )
   RETURNS DECIMAL(18, 2) 
   AS
   BEGIN
       DECLARE @VPL DECIMAL(18, 2) = 0;
       DECLARE @Valor DECIMAL(18, 2);
       DECLARE @Periodo INT;
       DECLARE @DataBase DATE = (SELECT MIN(DataMovimentacao) FROM MovimentacaoFinanceira);

       DECLARE MovimentacoesCursor CURSOR FOR 
       SELECT DATEDIFF(MONTH, @DataBase, DataMovimentacao) AS Periodo, Valor
       FROM MovimentacaoFinanceira;

       OPEN MovimentacoesCursor;
       FETCH NEXT FROM MovimentacoesCursor INTO @Periodo, @Valor;

       WHILE @@FETCH_STATUS = 0
       BEGIN
           SET @VPL = @VPL + @Valor / POWER((1 + @TaxaDesconto), @Periodo);
           FETCH NEXT FROM MovimentacoesCursor INTO @Periodo, @Valor;
       END;

       CLOSE MovimentacoesCursor;
       DEALLOCATE MovimentacoesCursor;

       RETURN @VPL;
   END;
   
   -- calculo do valor presente liquido (VPL)
     SELECT dbo.CalcularVPLGeral(0.05) AS VPLGeral;
   

CREATE FUNCTION CalcularTIR()
RETURNS DECIMAL(18, 5)
AS
BEGIN
    DECLARE @TIR DECIMAL(18, 5) = 0.0;
    DECLARE @Incremento DECIMAL(18, 5) = 0.00001;
    DECLARE @MaximoIteracoes INT = 10000;
    DECLARE @IteracaoAtual INT = 0;

    -- Função para calcular o VPL dado uma taxa de desconto
    DECLARE @VPL DECIMAL(18, 2);
    DECLARE @Valor DECIMAL(18, 2);
    DECLARE @Periodo INT;
    DECLARE @DataBase DATE = (SELECT MIN(DataMovimentacao) FROM MovimentacaoFinanceira);

    WHILE @IteracaoAtual < @MaximoIteracoes
    BEGIN
        SET @VPL = 0;

        DECLARE MovimentacoesCursor CURSOR FOR 
        SELECT DATEDIFF(MONTH, @DataBase, DataMovimentacao) AS Periodo, Valor
        FROM MovimentacaoFinanceira;

        OPEN MovimentacoesCursor;
        FETCH NEXT FROM MovimentacoesCursor INTO @Periodo, @Valor;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @VPL = @VPL + @Valor / POWER((1 + @TIR), @Periodo);
            FETCH NEXT FROM MovimentacoesCursor INTO @Periodo, @Valor;
        END;

        CLOSE MovimentacoesCursor;
        DEALLOCATE MovimentacoesCursor;

        -- Verifica se o VPL está próximo de zero
        IF ABS(@VPL) < 0.01 BREAK;
        SET @TIR = @TIR + @Incremento;
        SET @IteracaoAtual = @IteracaoAtual + 1;
    END

    RETURN @TIR;
END;

-- Cálculo de taxa interna de retorno (TIR)
SELECT dbo.CalcularTIR() AS TIR;