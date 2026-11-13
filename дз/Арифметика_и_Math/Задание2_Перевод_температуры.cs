using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Vvedite temperaturu po Farengeytu:");
        double f = Convert.ToDouble(Console.ReadLine());

        // tut 5.0 / 9.0 potomu chto 5 / 9 = 0 esli celye
        double c = 5.0 / 9.0 * (f - 32);

        Console.WriteLine("Celsiy: " + Math.Round(c, 2));
    }
}
