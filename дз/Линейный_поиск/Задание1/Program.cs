using System;

class Program
{
    // lineynyy poisk: idem sleva napravo i sravnivaem
    static int Find(int[] numbers, int target)
    {
        for (int i = 0; i < numbers.Length; i++)
        {
            if (numbers[i] == target)
            {
                return i; // nashli - srazu vyhodim
            }
        }

        return -1; // posle cikla znachit ne nashli
    }

    static void Main()
    {
        int[] arr = { 5, 3, 8, 1, 9, 2 };

        Console.WriteLine("Ishchem 8 -> index " + Find(arr, 8));
        Console.WriteLine("Ishchem 2 -> index " + Find(arr, 2));
        Console.WriteLine("Ishchem 7 -> index " + Find(arr, 7));

        // granichnyy sluchay - pustoy massiv
        int[] empty = new int[0];
        Console.WriteLine("Pustoy massiv -> index " + Find(empty, 1));
    }
}
