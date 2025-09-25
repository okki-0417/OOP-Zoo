namespace ZooSim.Models;

class IntroduceAnimal(Zoo zoo)
{
  private Zoo Zoo = zoo;
  public Dictionary<string, Action> IntroduceWayAndMethods => new()
  {
    { "購入する", BuyAnimal },
    { "繁殖させる", BreedAnimal },
    { "他園と交換する", TradeAnimal },
    { "保護する", RescueAnimal },
  };

  public List<string> IntroduceWayNames()
  {
    return [.. IntroduceWayAndMethods.Keys];
  }

  private void BuyAnimal()
  {
    var buyAnimal = new BuyAnimal();

    while (true)
    {
      if (Zoo.ContractedAnimalSellers.Count > 0)
      {
        Console.WriteLine("どの動物商人から買うか選択してください");
        AnimalSeller animalSeller = SelectAnimalSeller();

        Console.WriteLine("どの動物を買うか選択してください");
        BuyableAnimal buyingAnimal = SelectBuyingAnimal(animalSeller);

        if (ZooFinance.PayIfPayable(buyingAnimal.Price))
        {
          Animals.Add(buyingAnimal.Animal);
          Console.WriteLine($"{buyingAnimal.Animal.Name}を購入しました！");
          return;
        }
        else
        {
          Console.WriteLine("お金が足りません。");
          Console.WriteLine($"現在の資金：{ZooFinance.Funds}");
        }
      }
      else
      {
        Console.WriteLine("契約している動物商人がいません。");
        Console.WriteLine("まず動物商人と契約しましょう。");

        ContractWithAnimalSeller();
        continue;
      }
    }
  }

  private void BreedAnimal()
  {
    Console.WriteLine("動物を繁殖させる");
  }

  private void TradeAnimal()
  {
    Console.WriteLine("他園と動物を交換する");
  }

  private void RescueAnimal()
  {
    Console.WriteLine("動物を保護する");
  }
}
