using System;

class Program
{
    // sdvig na shift, esli shift otricatelnyy - rasshifrovka
    static string Crypt(string text, int shift)
    {
        string result = "";

        foreach (char c in text)
        {
            if (c >= 'a' && c <= 'z')
            {
                char ch = (char)((c - 'a' + shift + 26) % 26 + 'a');
                result = result + ch;
            }
            else if (c >= 'A' && c <= 'Z')
            {
                char ch = (char)((c - 'A' + shift + 26) % 26 + 'A');
                result = result + ch;
            }
            else
            {
                result = result + c; // probely, zapyatye i t.d. ne menyaem
            }
        }

        return result;
    }

    static void Main()
    {
        Console.WriteLine("Vvedite text:");
        string text = Console.ReadLine();

        int shift = 3;

        string secret = Crypt(text, shift);
        Console.WriteLine("Zashifrovano: " + secret);

        string opened = Crypt(secret, -shift);
        Console.WriteLine("Rasshifrovano: " + opened);
    }
}
