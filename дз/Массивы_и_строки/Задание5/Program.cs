using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Vvedite vyrazhenie (naprimer 10+20-5):");
        string expr = Console.ReadLine();

        // ubiraem probely, esli oni est
        expr = expr.Replace(" ", "");

        int result = 0;
        int sign = 1;
        string num = "";
        int start = 0;

        // esli vyrazhenie nachinaetsya s minusa
        if (expr[0] == '-')
        {
            sign = -1;
            start = 1;
        }

        for (int i = start; i < expr.Length; i++)
        {
            char c = expr[i];

            if (c >= '0' && c <= '9')
            {
                num = num + c;
            }
            else if (c == '+' || c == '-')
            {
                result = result + sign * Convert.ToInt32(num);
                num = "";

                if (c == '+') sign = 1;
                else sign = -1;
            }
        }

        // poslednee chislo
        result = result + sign * Convert.ToInt32(num);

        Console.WriteLine("Rezultat = " + result);
    }
}
