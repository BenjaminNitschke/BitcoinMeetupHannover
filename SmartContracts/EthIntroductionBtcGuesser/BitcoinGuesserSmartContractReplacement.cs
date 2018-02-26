using System;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace BitcoinGuesserSmartContractReplacement
{
	public partial class Program
	{
		public static void Main()
		{
			Console.WriteLine("Bitcoin Hannover Meetup Price Guesser ETH Smart Contract Replacement");
			decimal btcUsdPrice = 0;
			do
			{
				// Check every 15 minutes
				if (btcUsdPrice > 0)
					Thread.Sleep(15 * 60 * 1000);
				btcUsdPrice = GrabBtcUsdPrice();
				Console.WriteLine("Current BTC price: $" + btcUsdPrice);
			} while (btcUsdPrice >= 12500 && btcUsdPrice < 25000);
			Guess bestGuess = null;
			double bestGuesserDaysDistance = 10000.0;
			foreach (var guess in guesses)
			{
				double daysDistance = Math.Abs((guess.Date - DateTime.UtcNow.Date).TotalDays);
				if (daysDistance > bestGuesserDaysDistance)
					continue;
				bestGuess = guess;
				bestGuesserDaysDistance = daysDistance;
			}
			Console.WriteLine("Ending at " + DateTime.UtcNow + ", price=$" + btcUsdPrice +
				" reached ending condition, will pay out contract now to " + bestGuess.Name + ": " +
				bestGuess.EthAddress);
			var service = new EthereumService("http://localhost:8545/");
			Console.WriteLine("Final outgoing tx: "+service.SendSmartContractWinner(bestGuess.EthAddress));
			Console.ReadLine();
		}

		private static decimal GrabBtcUsdPrice() => GetBtcTicker().GetAwaiter().GetResult().price_usd;

		private static async Task<CoinMarketCapCurrencyTicker> GetBtcTicker()
		{
			try
			{
				var json = await GetHttpResponse("https://api.coinmarketcap.com/v1/ticker/bitcoin");
				return JsonConvert.DeserializeObject<CoinMarketCapCurrencyTicker[]>(json)[0];
			}
			catch (Exception ex)
			{
				Console.WriteLine("Failed to grab btc usd rate: " + ex.Message);
				// If service is down, just provide ruff fallback values
				return new CoinMarketCapCurrencyTicker { price_usd = 15093.23m };
			}
		}

		private static async Task<string> GetHttpResponse(string url)
			=> await (await new HttpClient(AutoDecompression).GetAsync(url)).Content.ReadAsStringAsync();

		public static HttpMessageHandler AutoDecompression
			=> new HttpClientHandler
			{
				AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate
			};

		private static Guess[] guesses =
		{
			new Guess
			{
				Name = "B*",
				Date = new DateTime(2018, 2, 11),
				EthAddress = "0xb748f2D797a924B44888A6744C22b46F3fF3aCdB"
			},
			new Guess
			{
				Name = "anonymous",
				Date = new DateTime(2018, 1, 20),
				EthAddress = "0x9b7338526b5f4fabe15401e4ade1622b0e2042c1"
			},
			new Guess
			{
				Name = "M*",
				Date = new DateTime(2018, 2, 18),
				EthAddress = "0xcac4dbc944dfcf4904dab859408ffbf730947741"
			},
			new Guess
			{
				Name = "unknown",
				Date = new DateTime(2018, 1, 17),
				EthAddress = "0x3bfc3f5832432f978c706d5f8f9e2f0db857300b"
			},
			new Guess
			{
				Name = "T*",
				Date = new DateTime(2018, 4, 1),
				EthAddress = "0x8Bdf2fB7AE659A975e22198cA6bAA4D66EF48511"
			},
			new Guess
			{
				Name = "R*",
				Date = new DateTime(2018, 3, 3),
				EthAddress = "0x764A197e8d34B9c08ce26ed976F7f8694B670AF0"
			},
			new Guess
			{
				Name = "G*",
				Date = new DateTime(2018, 1, 16),
				EthAddress = "0x3d88d28D2f81e350e6c2217d54d8eA0644a0023C"
			}
		};
	}
}
