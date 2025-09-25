namespace ZooSim.Models;

public class ZooOrganization
{
  public List<AnimalTrader>? ContractedAnimalTraders;

  public void ContractWithAnimalTrader()
  {
    AnimalTradeAgency.BrokerContractWithAnimalTrader();
  }
}
