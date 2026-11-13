using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Vvedite text:");
        string text = Console.ReadLine();

        string result = "";
        bool newSentence = true; // sleduyushchaya bukva - nachalo predlozheniya

        foreach (char c in text)
        {
            if (newSentence && char.IsLetter(c))
            {
                result = result + char.ToUpper(c);
                newSentence = false;
            }
            else
            {
                result = result + c;

                if (c == '.' || c == '!' || c == '?')
                {
                    newSentence = true;
                }
            }
        }

        Console.WriteLine(result);
    }
}
