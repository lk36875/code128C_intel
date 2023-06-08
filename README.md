# code128C_intel
Pisany w Asemblerze x86 dekoder kodów kreskowych typu 128C, sprawdzający ograniczenia oraz poprawność kodu podanego jako obraz bmp.

---
Łukasz Główka, 313803
---

Program dekodujący kody kreskowe zgodnie ze specyfikacją Code 128C.

# Struktura programu i danych

Program posiada następujące etapy:

1)  Odczytanie pliku w C++.

2)  Znalezienie najmniejszej kreski.

3)  Znalezienie pierwszej pustej przestrzeni i znaku startu.

4)  Znalezienie wzoru, zdekodowanie, powrót do szukania wzorów.

5)  Zdekodowanie znaku stopu, sprawdzenie sumy kontrolnej i pustej
    przestrzeni końcowej.

6)  Wypisanie wyniku na standardowym wyjściu.

Program korzysta z pliku constants.asm w którym zapisana jest tabela
kodów odpowiadające odpowiednim wzorom, które w postaci binarnej
posiadają jedynki w miejscu czarnej kreski i zera w miejscu białej
kreski.

Zdekodowane wzory program przechowuje na stosie, a pod koniec programu
dekoduje, oblicza sumę kontrolną i porównuje ją z odczytaną sumą.

# Implementacja

Program zaczyna się od przeczytania pliku bmp oraz zweryfikowaniu jego
poprawności w pliku C++. W pliku asm program rezerwuje potrzebną na
stosie pamięć. Następnie program oblicza najmniejszą kreskę przez
przesunięcie logiczne w prawo (podzielenie na 2) pierwszej czarnej
kreski, która w każdym kodzie jest równa długości dwa. Po obliczeniu
najmniejszej długości weryfikowane jest pojawienie się pustej
przestrzeni wymaganej przed kodem.

Następna część kodu znajduje ciąg sześciu kresek czarnych i białych --
gdy natrafi na zmianę koloru, dodaje kreskę do rejestru jako logiczne
przesunięcie w lewo oraz dodanie jedynki, a białą kreskę jako
przesunięcie logiczne w lewo bez dodania jedynki. Po dodaniu całego
ciągu powstaje binarna liczba mówiąca który kod został wczytany. W
programie pokazywane są jako liczby szesnastkowe i tak są one zapisane w
pliku data.asm.

Powstała z ciągu liczba jest porównywana z tymi w pliku. Po znalezieniu
liczby jest ona dekodowana przy pomocy licznika, którym iterujemy po
kodach z pliku constants.asm. Następnie liczba dodawana jest do rejestru
obliczającego sumę kontrolną. Po wykryciu pierwszego ciągu sprawdzany
jest znak startu.

W przypadku podejrzenia wykrycia znaku stop liczba jest sprawdzana pod
kątem zgodności ze znakiem stopu.

Po zdekodowaniu znaku stopu program sprawdza sumę kontrolną porównując
ją z sumą obliczoną z poprzednio wczytanych kodów. Następnie sprawdzana
jest wymagana pusta przestrzeń na końcu programu.

Wynik działania programu jest wypisywany na standardowym wyjściu.

# Testowanie

Aby odtworzyć testowane przypadki należy uruchomić podane pliki dla 24.
linijki.

Przy błędzie odczytu pliku pojawi się błąd \"File incorrect\", a przy
podaniu złej linijki \"Skanned line must be greater than 1 and lower
than height - 1.\". Brak podania linijki również skutkuje błędem \"You
must pass 2 arguments\".

Błędy:

<pre>
+-----------------------------------------+-------------+--------------+
| PLIK                                    | BŁĄD        | POWÓD        |
+=========================================+=============+==============+
| error_wrong_checksum.bmp                | Wrong       | Znak         |
|                                         | checksum    | kontrolny    |
|                                         | error       | nie jest     |
|                                         |             | prawidłowy.  |
+-----------------------------------------+-------------+--------------+
| error_out_of_range.bmp                  | Out of      | Błędny wzór. |
|                                         | range error |              |
| error_out_of_range_black.bmp            |             |              |
|                                         |             |              |
| error_out_of_range_white.bmp            |             |              |
+-----------------------------------------+-------------+--------------+
| error_wrong_start_code.bmp              | Wrong       | Zły kod      |
|                                         | pattern     | startu.      |
|                                         | error       |              |
+-----------------------------------------+-------------+--------------+
| error_no_spaces_after_code.bmp          | Wrong space | Brak pustej  |
|                                         | error       | przestrzeni  |
| error_no_spaces_before_code.bmp         |             | przed/po     |
|                                         |             | kodzie.      |
+-----------------------------------------+-------------+--------------+
| error_wrong_stop.bmp                    | Wrong stop  | Zły kod      |
|                                         | error       | stopu.       |
+-----------------------------------------+-------------+--------------+
| Abc.s                                   | Format of   | Nazwa pliku  |
|                                         | file is     | się nie      |
|                                         | wrong       | zgadza.      |
+-----------------------------------------+-------------+--------------+
</pre>

Pliki kod.bmp, kod2.bmp, kod3.bmp są poprawne.
