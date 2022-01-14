create function Produkty_szczegóły_w_danym_momencie_w_czasie (@when date)
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