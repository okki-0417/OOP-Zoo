namespace ZooSim.Models;
public class AnimalTrader
{
  public string Name { get;}
  public List<BuyableAnimal> BuyableAnimals = [];

  public AnimalTrader(string name)
  {
    Name = name;
    BuyableAnimals = [
      new BuyableAnimal(new Animal("ライオン"), 2000000),
      new BuyableAnimal(new Animal("トラ"), 2000000),
      new BuyableAnimal(new Animal("チンパンジー"), 1000000),
      new BuyableAnimal(new Animal("ゾウ"), 30000000),
      new BuyableAnimal(new Animal("カバ"), 10000000),
    ];

  }

  public void ListBuyableAnimals()
  {
    for (int i = 0; i < BuyableAnimals.Count; i++)
    {
      Console.WriteLine($"{i} -> {BuyableAnimals[i].Animal.Name}： ¥{BuyableAnimals[i].Price}");
    }
  }
}
