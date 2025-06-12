-- Wykorzystując metody typu XML należy utworzyć skrypt tworzący dokument XML zawierający listę studentów zawierającą imię, nazwisko i grupę. Kolejność instrukcji T-SQL tworzących dokument XML.

-- Tworzymy dokument XML zawierający element <lista>.
-- Dodajemy kolejnych studentów wykorzystując metodę „modify”. Dane studenta umieszczamy w strukturze <student><nazwisko/><imie/></student>.
-- Modyfikujemy dane studenta dodając na ostatniej pozycji w elemencie <student> element <grupa>.
-- Wykorzystując metodę „nodes” tworzymy zbiór rekordów zawierających element <student>.
-- Skrypt powinien utworzyć dokument zawierający co najmniej 5 węzłów <student/>.

use lab11;
go
declare @xdoc xml;
set @xdoc = '<?xml version="1.0" encoding="UTF-8" ?><lista/>';

set @xdoc.modify('insert <student><nazwisko>Senyszyn</nazwisko><imie>Adam</imie></student> as last into /lista[1]');
set @xdoc.modify('insert <student><nazwisko>Stanowski</nazwisko><imie>Bartosz</imie></student> as last into /lista[1]');
set @xdoc.modify('insert <student><nazwisko>Braun</nazwisko><imie>Dawid</imie></student> as last into /lista[1]');
set @xdoc.modify('insert <student><nazwisko>Nawrocki</nazwisko><imie>Aleksander</imie></student> as last into /lista[1]');
set @xdoc.modify('insert <student><nazwisko>Cholownia</nazwisko><imie>Szymon</imie></student> as last into /lista[1]');

set @xdoc.modify('insert <grupa>1</grupa> as last into /lista[1]/student[1]');
set @xdoc.modify('insert <grupa>2</grupa> as last into /lista[1]/student[2]');
set @xdoc.modify('insert <grupa>2</grupa> as last into /lista[1]/student[3]');
set @xdoc.modify('insert <grupa>3</grupa> as last into /lista[1]/student[4]');
set @xdoc.modify('insert <grupa>4</grupa> as last into /lista[1]/student[5]');

select Tab.col.value('(nazwisko)[1]', 'nvarchar(50)') as nazwisko,
       Tab.col.value('(imie)[1]', 'nvarchar(50)')     as imie,
       Tab.col.value('(grupa)[1]', 'int')             as grupa
from @xdoc.nodes('/lista/student') as Tab(col);