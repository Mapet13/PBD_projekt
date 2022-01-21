create index I_Klienci_firmowi_nazwa_firmy on Klienci_firmowi(nazwa_firmy)
create index I_Klienci_firmowi_nip on Klienci_firmowi(NIP)
create index I_Klienci_indywidualni_imie_nazwisko on Klienci_indywidualni(imię,nazwisko)


create index I_Menu on Menu(data_wprowadzenia)

create index I_Produkty_szczegóły on Produkty_szczegóły(data_wprowadzenia)

create index I_Przyznane_rabaty on Przyznane_rabaty(id_klienta)

create index I_Stałe on Stałe(data_wprowadzenia)

create index I_Stoliki_szczegóły on Stoliki_szczegóły(data_wprowadzenia)