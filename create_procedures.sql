create procedure Wystaw_fakture_miesieczną(@id_klienta int , @month date,@id_pracownika int)
as
begin
    declare @id_faktury int
    insert into Faktury values (@id_klienta,current_timestamp,1,@id_pracownika)
    select @id_faktury=SCOPE_IDENTITY()
    insert into Faktura_szczegóły
        select @id_faktury,Zamówienia.id_zamówienia from Zamówienia
        left outer join Faktura_szczegóły Fs on Zamówienia.id_zamówienia = Fs.id_zamówienia
        where YEAR(@month) = YEAR(data_złorzenia_zamówienia)
          and Month(@month) = MONTH(data_złorzenia_zamówienia)
          and id_faktury is null
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
