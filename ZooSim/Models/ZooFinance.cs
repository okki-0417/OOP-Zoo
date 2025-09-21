namespace ZooSim.Models;
public class ZooFinance
{
  public int Funds { get; set; } = 100000000;

  private bool IsPayable(int price) {
    return Funds >= price;
  }

  public bool PayIfPayable(int price)
  {
    if (IsPayable(price))
    {
      Funds -= price;
      return true;
    }
    else
    {
      return false;
    }
  }
}
