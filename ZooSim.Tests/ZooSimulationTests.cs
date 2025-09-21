using ZooSim.Models;

namespace ZooSim.Tests;

public class ZooSimulationTests
{
    [Fact]
    public void Constructor_WithValidInput_CreatesZooSimulation()
    {
        var input = new StringReader("Test Owner\nTest Zoo");
        var output = new StringWriter();
        Console.SetIn(input);
        Console.SetOut(output);

        var simulation = new ZooSimulation();

        Assert.NotNull(simulation);
        var consoleOutput = output.ToString();
        Assert.Contains("動物シミュレーションへようこそ！", consoleOutput);
        Assert.Contains("動物園のオーナーとして登録します！", consoleOutput);
        Assert.Contains("Test Ownerさん、これからよろしくお願いします！", consoleOutput);
        Assert.Contains("「Test Zoo」という名前で動物園を作りました！", consoleOutput);
    }

    [Fact]
    public void Constructor_WithEmptyOwnerName_RetriesUntilValidInput()
    {
        var input = new StringReader("\n \nValidOwner\nTest Zoo");
        var output = new StringWriter();
        Console.SetIn(input);
        Console.SetOut(output);

        var simulation = new ZooSimulation();

        Assert.NotNull(simulation);
        var consoleOutput = output.ToString();
        Assert.Contains("名前は空にできません。", consoleOutput);
        Assert.Contains("ValidOwnerさん、これからよろしくお願いします！", consoleOutput);
    }

    [Fact]
    public void Run_SelectOption2_ExitsGracefully()
    {
        var input = new StringReader("Test Owner\nTest Zoo\n2");
        var output = new StringWriter();
        Console.SetIn(input);
        Console.SetOut(output);

        var simulation = new ZooSimulation();
        simulation.Run();

        var consoleOutput = output.ToString();
        Assert.Contains("次の行動を選んでください。", consoleOutput);
        Assert.Contains("さようなら！", consoleOutput);
    }

    [Fact]
    public void Run_InvalidOption_ShowsErrorMessage()
    {
        var input = new StringReader("Test Owner\nTest Zoo\n99\n2");
        var output = new StringWriter();
        Console.SetIn(input);
        Console.SetOut(output);

        var simulation = new ZooSimulation();
        simulation.Run();

        var consoleOutput = output.ToString();
        Assert.Contains("選択肢のいずれかを入力してください！", consoleOutput);
    }

    [Fact]
    public void Run_SelectOption1_CallsIntroduceNewAnimal()
    {
        var input = new StringReader("Test Owner\nTest Zoo\n1\n4\n2");
        var output = new StringWriter();
        Console.SetIn(input);
        Console.SetOut(output);

        var simulation = new ZooSimulation();
        simulation.Run();

        var consoleOutput = output.ToString();
        Assert.Contains("Test Zooに新しい動物を導入する", consoleOutput);
        Assert.Contains("どうやって新しい動物を導入しますか？", consoleOutput);
    }
}
