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
