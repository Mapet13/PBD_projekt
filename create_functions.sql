create function Produkty_szczegóły_w_danym_momencie_w_czasie (@when datetime)   -- zwraca ceny produktów, które obowiązywały w momencie @when
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

create function Stałe_w_danym_momencie_w_czasie (@when datetime)    -- zwraca stałe, które obowiązywały w momencie @when
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


create function Menu_w_danym_momencie_w_czasie (@when datetime)     -- zwraca menu, ktore obowiązywało w momencie @when
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


create function Stoliki_szczegóły_w_danym_momencie_w_czasie (@when datetime)    -- zwraca szczegóły stolików, które obowiązywały w momencie @when
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

create function Procent_rabatu (@id_rabatu int)     -- zwraca wielkosc znizki zapewnianej przez dany rabat
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


create function Wartość_zamówienia (@id_zamówienia int)     -- zlicza łączną wartość produktów należących do danego zamówienia
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


-- Raporty dotyczą danych w przedziale czasowym od @data_start (lub bez ograniczenia dla @data_start = null)
-- do @data_end (lub do chwili obecnej dla @data_end = null

create function Raport_stoliki(@data_start datetime = null, @data_end datetime = null)      -- Raport dotyczacy stolikow
returns table
as return (
    select Stoliki.id_stołu,count(Rs.id_rezerwacji) as 'ilosc rezerwacji stolika' from Stoliki
          join Rezerwacje_stolików Rs on Stoliki.id_stołu = Rs.id_stołu
          join Rezerwacje R2 on R2.id_rezerwacji = Rs.id_rezerwacji
          where (@data_start is null or @data_start <=R2.data_rezerwacji)
            and (@data_end is null or @data_end >=R2.data_rezerwacji)
          group by Stoliki.id_stołu
    )



create function Raport_rabaty(@data_start datetime = null, @data_end datetime = null)   -- Raport dotyczacy rabatów
returns table
as return (
    select T1.[typ rabatu],[wykorzystane rabaty],[przyznane rabaty] from
    (select dbo.Typ_rabatu(Przyznane_rabaty.id_rabatu) as 'typ rabatu', count(id_zamówienia) as 'wykorzystane rabaty'
     from Przyznane_rabaty
              join Zamówienia Z on Przyznane_rabaty.id_rabatu = Z.id_rabatu
     where (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
       and (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
     group by dbo.Typ_rabatu(Przyznane_rabaty.id_rabatu)
    ) T1 join (select dbo.Typ_rabatu(id_rabatu) as 'typ rabatu', count(id_rabatu) as 'przyznane rabaty' from Przyznane_rabaty
        where (@data_start is null or @data_start <= Przyznane_rabaty.data_przyznania)
       and (@data_end is null or @data_end >= Przyznane_rabaty.data_przyznania)
        group by dbo.Typ_rabatu(id_rabatu)
    ) T2 on T1.[typ rabatu]=T2.[typ rabatu]
)



create function Raport_rabaty_dla_klienta(@id_klienta int,@data_start datetime = null, @data_end datetime = null)   -- Raport dotyczący rabatów wykorzystanych przez danego klienta
returns table
as return (
    select T1.[typ rabatu],[wykorzystane rabaty],[przyznane rabaty] from
    (select dbo.Typ_rabatu(Przyznane_rabaty.id_rabatu) as 'typ rabatu', count(id_zamówienia) as 'wykorzystane rabaty'
     from Przyznane_rabaty
              join Zamówienia Z on Przyznane_rabaty.id_rabatu = Z.id_rabatu
     where (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
       and (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
        and Przyznane_rabaty.id_klienta = @id_klienta
     group by dbo.Typ_rabatu(Przyznane_rabaty.id_rabatu)
    ) T1 join (select dbo.Typ_rabatu(id_rabatu) as 'typ rabatu', count(id_rabatu) as 'przyznane rabaty' from Przyznane_rabaty
        where (@data_start is null or @data_start <= Przyznane_rabaty.data_przyznania)
       and (@data_end is null or @data_end >= Przyznane_rabaty.data_przyznania)
    and Przyznane_rabaty.id_klienta = @id_klienta
        group by dbo.Typ_rabatu(id_rabatu)
    ) T2 on T1.[typ rabatu]=T2.[typ rabatu]
)
create function Raport_menu(@data_start datetime = null, @data_end datetime = null)     -- Raport dotyczacy menu oraz tego jak czesto wybierane sa dane produkty
returns table
as return
    (
        select id_produktu, count(id_produktu) as "ilosc zamowien produktu" from dbo.Zamówienia_szczegóły as Zs
        join dbo.Zamówienia Z on Zs.id_zamówienia = Z.id_zamówienia
        where (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
         and  (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
        group by id_produktu
    )


create function Raport_zamowienia(@data_start datetime = null, @data_end datetime = null)   -- Raport dotyczacy zamowien
returns table
as return
    (
        select COUNT(*) as 'ilosc zamowien',
               SUM(dbo.Wartość_zamówienia(Z.id_zamówienia)) as 'ilosc wydanych pieniedzy',
               MAX(dbo.Wartość_zamówienia(Z.id_zamówienia)) as 'najdrozsze zamowienie',
               AVG(dbo.Wartość_zamówienia(Z.id_zamówienia)) as 'srednia wartosc zamowienia',
               AVG(DATEPART(hour,Z.data_złorzenia_zamówienia)) as 'zwykle klienci przychodza o tej porze'
            from Zamówienia as Z
        where (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
        and (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
    )

create function Raport_zamowienia_klient(@ID_klienta INT, @data_start datetime = null, @data_end datetime = null)   -- Raport dotyczacy zamowien skladanych przez danego klienta
returns table
as return
    (
        select COUNT(*) as 'ilosc zamowien',
               SUM(dbo.Wartość_zamówienia(Z.id_zamówienia)) as 'ilosc wydanych pieniedzy',
               AVG(dbo.Wartość_zamówienia(Z.id_zamówienia)) as 'srednia wartosc zamowienia',
               AVG(DATEPART(hour, Z.data_złorzenia_zamówienia)) as 'zazwyczaj kupuje o tej porze'
        from Zamówienia as Z
        where Z.id_klienta = @ID_klienta
        and (@data_start is null or @data_start <= Z.data_złorzenia_zamówienia)
        and (@data_end is null or @data_end >= Z.data_złorzenia_zamówienia)
    )
go

create function dostępne_rabaty(@id_klienta int)
returns table
as
    return
        (
            (select Prt1.id_rabatu, (select R1 from Stałe_w_danym_momencie_w_czasie(data_przyznania)) as procent, null as data_wygaśnięcia
             from Przyznane_rabaty_typu_1 Prt1
                      join Przyznane_rabaty Pr on Pr.id_rabatu = Prt1.id_rabatu
            left outer join Zamówienia Z on Pr.id_rabatu = Z.id_rabatu
             where Pr.id_klienta = @id_klienta and Z.id_zamówienia is null)
            union
            (
                select Prt2.id_rabatu, (select R2 from Stałe_w_danym_momencie_w_czasie(data_przyznania))  as procent, dateadd(d,(select D1 from Stałe_w_danym_momencie_w_czasie(data_przyznania)),data_przyznania) as data_wygaśnięcia
             from Przyznane_rabaty_typu_2 Prt2
                      join Przyznane_rabaty Pr on Pr.id_rabatu = Prt2.id_rabatu
            left outer join Zamówienia Z on Pr.id_rabatu = Z.id_rabatu
             where Pr.id_klienta = @id_klienta and Z.id_zamówienia is null and dateadd(d,(select D1 from Stałe_w_danym_momencie_w_czasie(data_przyznania)),data_przyznania) > current_timestamp)
            union

            (select Prtm.id_rabatu, procent  as procent, null as data_wygaśnięcia
             from Przyznane_rabaty_typu_manager Prtm
                      join Przyznane_rabaty Pr on Pr.id_rabatu = Prtm.id_rabatu
            left outer join Zamówienia Z on Pr.id_rabatu = Z.id_rabatu
             where Pr.id_klienta = @id_klienta and Z.id_zamówienia is null)

        )
