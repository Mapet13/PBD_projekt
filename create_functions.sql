create function Produkty_szczegóły_w_danym_momencie_w_czasie (@when datetime)
RETURNS table
as Return (
    with tab as (
        select * from Produkty_szczegóły
        where  data_wprowadzenia < @when
    )
    select PS1.id_produktu,PS1.cena from tab PS1
    left outer join tab PS2 on PS1.data_wprowadzenia<PS2.data_wprowadzenia
    where PS2.data_wprowadzenia is null
    )

create function Stałe_w_danym_momencie_w_czasie (@when datetime)
RETURNS table
as Return (
    with tab as (
        select * from Stałe
        where  data_wprowadzenia < @when
    )
    select PS1.* from tab PS1
    left outer join tab PS2 on PS1.data_wprowadzenia<PS2.data_wprowadzenia
    where PS2.data_wprowadzenia is null
    )


create function Menu_w_danym_momencie_w_czasie (@when datetime)
RETURNS table
as Return (
    with tab as (
        select * from Menu
        where  data_wprowadzenia < @when
    )
    select PS1.* from tab PS1
    left outer join tab PS2 on PS1.data_wprowadzenia<PS2.data_wprowadzenia
    where PS2.data_wprowadzenia is null
    )


create function Stoliki_szczegóły_w_danym_momencie_w_czasie (@when datetime)
RETURNS table
as Return (
    with tab as (
        select * from Stoliki_szczegóły
        where  data_wprowadzenia < @when
    )
    select PS1.* from tab PS1
    left outer join tab PS2 on PS1.data_wprowadzenia<PS2.data_wprowadzenia
    where PS2.data_wprowadzenia is null
    )

create function Procent_rabatu (@id_rabatu int)
RETURNS float
as begin
    declare @when datetime
    if @id_rabatu is null
        return 0
    select @when = data_przyznania from Przyznane_rabaty where id_rabatu = @id_rabatu

    if @id_rabatu in (select id_rabatu from Przyznane_rabaty_typu_2)
        return (select R2 from Stałe_w_danym_momencie_w_czasie(@when))
    if @id_rabatu in (select id_rabatu from Przyznane_rabaty_typu_manager)
        return(select procent from Przyznane_rabaty_typu_manager where id_rabatu = @id_rabatu)
    if @id_rabatu in (select id_rabatu from Przyznane_rabaty_typu_1)
        return(select R1 from Stałe_w_danym_momencie_w_czasie(@when))
    return 0
end


create function Wartość_zamówienia (@id_zamówienia int)
RETURNS money
as begin
    declare @when datetime
    declare @procent float
    select @when = data_złorzenia_zamówienia from Zamówienia where id_zamówienia=@id_zamówienia
    select @procent = dbo.Procent_rabatu(id_rabatu) from Zamówienia where id_zamówienia=@id_zamówienia
    return (select sum(Produkty_szczegóły_w_danym_momencie_w_czasie.cena * Zs.ilość* (1.0-@procent)) from Zamówienia_szczegóły Zs
        join Produkty P on P.id_produktu = Zs.id_produktu
        join Produkty_szczegóły_w_danym_momencie_w_czasie(@when) on Produkty_szczegóły_w_danym_momencie_w_czasie.id_produktu=P.id_produktu
        where id_zamówienia= @id_zamówienia)
end


create function Raport_menu(@data_start datetime = null, @data_end datetime = null)
returns table
as return
    (
        select id_produktu, count(id_produktu) as "ilosc zamowien produktu" from dbo.Zamówienia_szczegóły as Zs
        join dbo.Zamówienia Z on Zs.id_zamówienia = Z.id_zamówienia
        where (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
         and  (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
        group by id_produktu
    )