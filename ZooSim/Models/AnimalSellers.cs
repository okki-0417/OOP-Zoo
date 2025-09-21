namespace ZooSim.Models;
public class AnimalSellers
{
  static public List<AnimalSeller> AllAnimalSellers { get; set; } = [];

  static public void ListAllAnimalSellers()
  {
    Console.WriteLine("動物商人の一覧");

    for (int i = 0; i < AllAnimalSellers.Count; i++)
    {
      Console.WriteLine($"{i} -> {AllAnimalSellers[i].Name}");
    }
  }
}
