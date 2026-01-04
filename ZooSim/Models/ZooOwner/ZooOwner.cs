namespace ZooSim.Models.ZooOwner;
using ZooSim.Models.Zoo;

public class ZooOwner(ZooOwnerName name, ZooName zooName)
{
  public ZooOwnerName Name { get; set; } = name;
  public Zoo Zoo { get; set; } = new(zooName);
}
