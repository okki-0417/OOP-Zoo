namespace ZooSim.Models;
using System.Diagnostics.Contracts;
public class Zoo
{
  const int MaximumNameLength = 255;
  private readonly string Name;
  private readonly ZooFinance ZooFinance;
  private readonly List<Animal> Animals = [];
  private List<AnimalSeller> ContractedAnimalSellers = [];

  public Zoo(string name)
  {
    Name = name;
    ZooFinance = new ZooFinance();
    Validate();

    Console.WriteLine($"「{Name}」という名前で動物園を作りました！");
  }

  public void IntroduceNewAnimal()
  {
    Console.WriteLine($"{Name}に新しい動物を導入する");

    Console.WriteLine("どうやって新しい動物を導入しますか？");
    Console.WriteLine("1 -> 購入する");
    Console.WriteLine("2 -> 繁殖させる");
    Console.WriteLine("3 -> 他園と取引する");
    Console.WriteLine("4 -> 保護する");

    string? input = Console.ReadLine();

    while (true)
    {
      try
      {
        switch (input)
        {
          case "1":
            BuyAnimal();
            break;
          case "2":
            BreedAnimal();
            break;
          case "3":
            TradeAnimal();
            break;
          case "4":
            RescueAnimal();
            break;
          default:
            throw new ArgumentException("選択肢の中から選んでください。");
        }

        return;
      }
      catch (ArgumentException ex)
      {
        Console.WriteLine($"{ex.Message}");
      }
    }
  }

  private void ListAnimals()
  {
    Console.WriteLine($"{Name}で飼育している動物の一覧");
    if (Animals.Count == 0)
    {
      Console.WriteLine("現在、飼育している動物はいません。");
      return;
    }

    foreach (var animal in Animals)
    {
      Console.WriteLine($"{animal.Name}");
    }
  }

  private void Validate()
  {
    if (string.IsNullOrWhiteSpace(Name))
    {
      throw new ArgumentException("名前は空にできません。");
    }

    if (Name.Length > MaximumNameLength)
    {
      throw new ArgumentException($"名前は{MaximumNameLength}文字以内にしてください。");
    }
  }

  private void BuyAnimal()
  {
    Console.WriteLine("動物を購入する");

    while (true)
    {
      if (ContractedAnimalSellers.Count > 0)
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

  public void ContractWithAnimalSeller()
  {
    AnimalSellers.ListAllAnimalSellers();

    Console.WriteLine("どの動物商人と契約するか選択してください");
    string? input;

    while (true)
    {
      input = Console.ReadLine();

      if (int.TryParse(input, out int index))
      {
        if (index >= 0 && index < AnimalSellers.AllAnimalSellers.Count)
        {
          AnimalSeller contractingAnimalSeller = AnimalSellers.AllAnimalSellers[int.Parse(input)];
          ContractedAnimalSellers.Add(contractingAnimalSeller);
          Console.WriteLine($"{contractingAnimalSeller.Name}と契約しました！");

          return;
        }
        else
        {
          Console.WriteLine("入力された内容は選択肢にありません。");
        }
      }
      else
      {
        Console.WriteLine("入力された内容は数値ではありません。");
      }
    }
  }

  private void ListContractedAnimalSellers()
  {
    for (int i = 0; i < ContractedAnimalSellers.Count; i++)
    {
      Console.WriteLine($"{i} -> {ContractedAnimalSellers[i].Name}");
    }
  }

  private AnimalSeller SelectAnimalSeller()
  {
    ListContractedAnimalSellers();

    string? input;

    while (true)
    {
      input = Console.ReadLine();

      if (int.TryParse(input, out int index))
      {
        if (index >= 0 && index < AnimalSellers.AllAnimalSellers.Count)
        {
          return ContractedAnimalSellers[int.Parse(input)];
        }
        else
        {
          Console.WriteLine("入力された内容は選択肢にありません。");
        }
      }
      else
      {
        Console.WriteLine("入力された内容は数値ではありません。");
      }
    }
  }

  static private BuyableAnimal SelectBuyingAnimal(AnimalSeller animalSeller)
  {
    animalSeller.ListBuyableAnimals();

    Console.WriteLine("購入する動物を選択してください。");

    string? input;

    while (true)
    {
      input = Console.ReadLine();

      if (int.TryParse(input, out int index))
      {
        if (index >= 0 && index < animalSeller.BuyableAnimals.Count)
        {
          return animalSeller.BuyableAnimals[int.Parse(input)];
        }
        else
        {
          Console.WriteLine("入力された内容は選択肢にありません。");
        }
      }
      else
      {
        Console.WriteLine("入力された内容は数値ではありません。");
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
