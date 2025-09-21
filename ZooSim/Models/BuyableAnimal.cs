namespace ZooSim.Models;
public class BuyableAnimal
{
  public Animal Animal;
  public int Price;

  public BuyableAnimal(Animal animal, int price)
  {
    Animal = animal;
    Price = price;
  }
}
