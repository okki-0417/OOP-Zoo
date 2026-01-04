
namespace ZooSim.Models.Zoo;
using ZooSim.Models.Animal;

public class Zoo(ZooName zooName)
{
  public ZooName Name = zooName;
  private readonly List<Animal> Animals = [];

  // private void ListAnimals()
  // {
  //   Console.WriteLine($"{Name}で飼育している動物の一覧");
  //   if (Animals.Count == 0)
  //   {
  //     Console.WriteLine("現在、飼育している動物はいません。");
  //     return;
  //   }

  //   foreach (var animal in Animals)
  //   {
  //     Console.WriteLine($"{animal.Name}");
  //   }
  // }

  // private void BuyAnimal()
  // {
  //   Console.WriteLine("動物を購入する");

  //   while (true)
  //   {
  //     if (ContractedAnimalTraders.Count > 0)
  //     {
  //       Console.WriteLine("どの動物商人から買うか選択してください");
  //       AnimalTrader animalTrader = SelectAnimalTrader();

  //       Console.WriteLine("どの動物を買うか選択してください");
  //       BuyableAnimal buyingAnimal = SelectBuyingAnimal(animalTrader);

  //       if (ZooFinance.PayIfPayable(buyingAnimal.Price))
  //       {
  //         Animals.Add(buyingAnimal.Animal);
  //         Console.WriteLine($"{buyingAnimal.Animal.Name}を購入しました！");
  //         return;
  //       }
  //       else
  //       {
  //         Console.WriteLine("お金が足りません。");
  //         Console.WriteLine($"現在の資金：{ZooFinance.Funds}");
  //       }
  //     }
  //     else
  //     {
  //       Console.WriteLine("契約している動物商人がいません。");
  //       Console.WriteLine("まず動物商人と契約しましょう。");

  //       ContractWithAnimalTrader();
  //       continue;
  //     }
  //   }
  // }

  // public void ContractWithAnimalTrader()
  // {
  //   AnimalSellers.ListAllAnimalSellers();

  //   Console.WriteLine("どの動物商人と契約するか選択してください");
  //   string? input;

  //   while (true)
  //   {
  //     input = Console.ReadLine();

  //     if (int.TryParse(input, out int index))
  //     {
  //       if (index >= 0 && index < AnimalSellers.AllAnimalSellers.Count)
  //       {
  //         AnimalTrader contractingAnimalTrader = AnimalSellers.AllAnimalSellers[int.Parse(input)];
  //         ContractedAnimalTraders.Add(contractingAnimalTrader);
  //         Console.WriteLine($"{contractingAnimalTrader.Name}と契約しました！");

  //         return;
  //       }
  //       else
  //       {
  //         Console.WriteLine("入力された内容は選択肢にありません。");
  //       }
  //     }
  //     else
  //     {
  //       Console.WriteLine("入力された内容は数値ではありません。");
  //     }
  //   }
  // }

  // private void ListContractedAnimalTraders()
  // {
  //   for (int i = 0; i < ContractedAnimalTraders.Count; i++)
  //   {
  //     Console.WriteLine($"{i} -> {ContractedAnimalTraders[i].Name}");
  //   }
  // }

  // private AnimalTrader SelectAnimalTrader()
  // {
  //   ListContractedAnimalTraders();

  //   string? input;

  //   while (true)
  //   {
  //     input = Console.ReadLine();

  //     if (int.TryParse(input, out int index))
  //     {
  //       if (index >= 0 && index < AnimalSellers.AllAnimalSellers.Count)
  //       {
  //         return ContractedAnimalTraders[int.Parse(input)];
  //       }
  //       else
  //       {
  //         Console.WriteLine("入力された内容は選択肢にありません。");
  //       }
  //     }
  //     else
  //     {
  //       Console.WriteLine("入力された内容は数値ではありません。");
  //     }
  //   }
  // }

  // static private BuyableAnimal SelectBuyingAnimal(AnimalTrader animalTrader)
  // {
  //   animalTrader.ListBuyableAnimals();

  //   Console.WriteLine("購入する動物を選択してください。");

  //   string? input;

  //   while (true)
  //   {
  //     input = Console.ReadLine();

  //     if (int.TryParse(input, out int index))
  //     {
  //       if (index >= 0 && index < animalTrader.BuyableAnimals.Count)
  //       {
  //         return animalTrader.BuyableAnimals[int.Parse(input)];
  //       }
  //       else
  //       {
  //         Console.WriteLine("入力された内容は選択肢にありません。");
  //       }
  //     }
  //     else
  //     {
  //       Console.WriteLine("入力された内容は数値ではありません。");
  //     }
  //   }
  // }

  // private void BreedAnimal()
  // {
  //   Console.WriteLine("動物を繁殖させる");
  // }

  // private void TradeAnimal()
  // {
  //   Console.WriteLine("他園と動物を交換する");
  // }

  // private void RescueAnimal()
  // {
  //   Console.WriteLine("動物を保護する");
  // }
}
