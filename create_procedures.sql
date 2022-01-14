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
