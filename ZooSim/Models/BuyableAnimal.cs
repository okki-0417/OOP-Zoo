namespace ZooSim.Models;

public class BuyableAnimal(Animal animal, int price)
{
    public Animal Animal { get; } = animal;
    public int Price { get; } = price;
}