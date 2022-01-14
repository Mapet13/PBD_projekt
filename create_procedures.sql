create procedure Wystaw_fakture_miesieczną(@id_klienta int , @month date,@id_pracownika int)
as
begin
    declare @id_faktury int
    declare @zamówienia table(id_zamówienia int)
    insert into @zamówienia select Zamówienia.id_zamówienia from Zamówienia
        left outer join Faktura_szczegóły Fs on Zamówienia.id_zamówienia = Fs.id_zamówienia
        where YEAR(@month) = YEAR(data_złorzenia_zamówienia)
          and Month(@month) = MONTH(data_złorzenia_zamówienia)
          and id_faktury is null
    if (select count(id_zamówienia) from @zamówienia) = 0
        return
    insert into Faktury values (@id_klienta,current_timestamp,1,@id_pracownika)
    select @id_faktury=SCOPE_IDENTITY()
    insert into Faktura_szczegóły
        select @id_faktury,id_zamówienia from @zamówienia
end


create procedure Wystaw_fakture(@id_klienta int ,@id_zamówienia int,@id_pracownika int)
as
begin
    declare @id_faktury int
    if @id_zamówienia in (select id_zamówienia from Faktura_szczegóły)
        raiserror('zamówienie jest już na jakiejś fakturze',5,0)
    insert into Faktury values (@id_klienta,current_timestamp,1,@id_pracownika)
    select @id_faktury=SCOPE_IDENTITY()
    insert into Faktura_szczegóły values (@id_faktury,@id_zamówienia)
end

CREATE procedure dodaj_stolik(
    @liczba_miejsc INT, @opis text, @id_pracownika INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Stoliki (data_dodania, czy_aktualnie_istnieje)
    VALUES (CURRENT_TIMESTAMP, 1);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Stoliki_szczegóły (id_stołu, liczba_miejsc, data_wprowadzenia, id_pracownika_dodającego, opis)
    VALUES (@id, @liczba_miejsc, CURRENT_TIMESTAMP, @id_pracownika, @opis);
end

CREATE procedure dodaj_produkt(
    @nazwa nvarchar(50), @czy_zawiera_produkt_morza bit, @id_kategorii int, @cena int, @id_pracownika int
)
AS
begin
    DECLARE @product_id INT;

    INSERT INTO Produkty (nazwa, czy_zawiera_owoce_morza, id_kategorii, data_dodania)
    VALUES (@nazwa, @czy_zawiera_produkt_morza, @id_kategorii, CURRENT_TIMESTAMP);

    SET @product_id = SCOPE_IDENTITY();

    INSERT INTO Produkty_szczegóły (id_produktu, cena, data_wprowadzenia, id_pracownika_dodającego)
    VALUES (@product_id, @cena, CURRENT_TIMESTAMP, @id_pracownika);
end


create procedure Dodaj_klienta_firmowego(@email nvarchar(200), @adres nvarchar(200),@NIP varchar(10),@nazwa_firmy nvarchar(200))
as
    begin
        declare @id_klienta int
        insert into Klienci (data_dodania, email, adres) values (current_timestamp,@email,@adres)
        set @id_klienta = scope_identity()
        insert into Klienci_firmowi (NIP, id_klienta, nazwa_firmy) values (@NIP,@id_klienta,@nazwa_firmy)
    end


create procedure Dodaj_klienta_indywidualnego(@email nvarchar(200), @adres nvarchar(200),@imie nvarchar(50), @nazwisko nvarchar(50), @pesel char(11))
as
    begin
        declare @id_klienta int
        insert into Klienci (data_dodania, email, adres) values (current_timestamp,@email,@adres)
        set @id_klienta = scope_identity()
        insert into Klienci_indywidualni (imię, nazwisko, pesel, id_klienta) values (@imie,@nazwisko,@pesel,@id_klienta)
    end
CREATE procedure dodaj_rabat_typu_manager(
@id_klienta INT , @procent INT, @id_pracownika INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_manager (id_rabatu, procent, id_pracownika)
    VALUES (@id, @procent, @id_pracownika);
end

CREATE procedure dodaj_rabat_typu_1(
@id_klienta INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_1 (id_rabatu)
    VALUES (@id);
end

CREATE procedure dodaj_rabat_typu_2(
@id_klienta INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_2 (id_rabatu, data_wykorzystania)
    VALUES (@id, NULL);
end


create procedure Dodaj_rezerwacje_indywidualną(@id_zamówienia int, @liczba_osób int)
as begin
    declare @id_klienta int
    declare @kiedy_zamówiono datetime
    declare @WK int
    declare @WZ money
    declare @data_realizacji datetime
    declare @WZs varchar(50)
    select @kiedy_zamówiono=data_złorzenia_zamówienia,@data_realizacji=data_oczekiwanej_realizacji from Zamówienia where id_zamówienia=@id_zamówienia
    select @Wk = WK,@WZ=WZ from dbo.Stałe_w_danym_momencie_w_czasie(@kiedy_zamówiono)
    Set @WZs = convert(varchar(50),@WZ,0)
    select @id_klienta=id_klienta from Zamówienia where id_zamówienia=@id_zamówienia
    if (select count(id_zamówienia) from Zamówienia where id_klienta = @id_klienta and data_złorzenia_zamówienia < @kiedy_zamówiono) < @WK
        raiserror('by złorzyć rezerwacje trzeba mieć wcześniej złożonych conajmniej %d zamówień',5,0,@WK)
    if dbo.Wartość_zamówienia(@id_zamówienia)<@WZ
        raiserror('rezerwacje można złorzyć wyłącznie do zamówienia za minimum %s zł',5,1,@WZs)
    if (select data_oczekiwanej_realizacji from Zamówienia where id_zamówienia = @id_zamówienia) < current_timestamp
        raiserror('nie można złorzyć rezerwacji na zamówienie które już mineło',5,1)
    insert into Rezerwacje values (@id_klienta,@data_realizacji)
    declare @id_rezerwacji int
    set @id_rezerwacji = SCOPE_IDENTITY()
    insert into Rezerwacje_indywidualne values (@id_rezerwacji,null,@id_zamówienia,@liczba_osób,null,0)
end