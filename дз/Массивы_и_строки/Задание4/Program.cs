using System;

class Program
{
    static void Print(int[,] m)
    {
        for (int i = 0; i < m.GetLength(0); i++)
        {
            for (int j = 0; j < m.GetLength(1); j++)
            {
                Console.Write(m[i, j] + "\t");
            }
            Console.WriteLine();
        }
    }

    static void Main()
    {
        int[,] A = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } };
        int[,] B = { { 9, 8, 7 }, { 6, 5, 4 }, { 3, 2, 1 } };
        int n = 3;
        int k = 2;

        Console.WriteLine("Matrica A:");
        Print(A);
        Console.WriteLine("Matrica B:");
        Print(B);

        // umnozhenie matricy na chislo
        int[,] C = new int[n, n];
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < n; j++)
            {
                C[i, j] = A[i, j] * k;
            }
        }
        Console.WriteLine("A * " + k + ":");
        Print(C);

        // slozhenie matrice
        int[,] D = new int[n, n];
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < n; j++)
            {
                D[i, j] = A[i, j] + B[i, j];
            }
        }
        Console.WriteLine("A + B:");
        Print(D);

        // proizvedenie matrice
        int[,] E = new int[n, n];
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < n; j++)
            {
                for (int t = 0; t < n; t++)
                {
                    E[i, j] = E[i, j] + A[i, t] * B[t, j];
                }
            }
        }
        Console.WriteLine("A * B:");
        Print(E);
    }
}
