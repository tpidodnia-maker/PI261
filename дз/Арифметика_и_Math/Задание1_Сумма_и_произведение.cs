using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Vvedite trehznachnoe chislo:");
        int number = Convert.ToInt32(Console.ReadLine());

        int hund = number / 100; // sotni
        int tens = number % 100 / 10; // desyatki
        int ones = number % 10; // edinicy

        int sum = hund + tens + ones;
        int mul = hund * tens * ones;

        Console.WriteLine("Summa = " + sum);
        Console.WriteLine("Proizvedenie = " + mul);
    }
}
