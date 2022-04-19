defmodule Testebot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
        cond do
            #0 command
            String.starts_with?(msg.content, "!command") ->
                Api.create_message(msg.channel_id,
                "
                Funcionalidades:
1- !erboss nome: Elden Ring API - Obter informações sobre o jogo por consulta get na API. obtém informações de itens, armas, armaduras, mobs, chefes e talismãs.
2- !pokedex nome/numero: Exibe informações básicas sobre determinado pokemon por nome ou número, utilizando a PokeAPI
3- !weather cidade: Exibe relatório geral climático de determinada cidade, com informações complementares, utilizando a OpenWeather API
4- !tweetsearch keyword: Pesquisa os 10 tweets mais recentes e detalhes contendo a palavra chave fornecida. Requer conta/token apropriado e utiliza a API oficial do twitter.
5- !govstats: Alguma estatística utilizando a API de dados gov br/portal da transparência. Se possível trabalhar dados e exibir em uma gráfico através da Image-Charts
6- !generateqr link: gera qr code copiável para qualquer link fornecido.
7- !lifeadvice: Gera conselho aleatório sobre a vida chamado por Advice Slip
8- !startup: Gera uma definição de StartUp
9- !pokemonin cidade: Acessa a API Openweather, obtém o clima da cidade fornecida e retorna uma lista de 10 pokemons (Acessando a pokeAPI) adequados para aquela cidade
10- !dadjoke: gera dad joke anonima

                ")

            #1
            String.starts_with?(msg.content, "!erboss ") -> eldenring_boss_query(msg)
            String.starts_with?(msg.content, "!erboss") ->
                Api.create_message(msg.channel_id, "Use **!erboss <Nome>**.")
            #2
            String.starts_with?(msg.content, "!pokedex ") -> pokedex_query(msg)
            String.starts_with?(msg.content, "!pokedex") ->
                Api.create_message(msg.channel_id, "Use **!pokedex <Nome>**.")

            #3
            String.starts_with?(msg.content, "!weather ") -> weather_query(msg)
            String.starts_with?(msg.content, "!weather") ->
                Api.create_message(msg.channel_id, "Use **!weather <Nome da cidade>**.")
            #4
            String.starts_with?(msg.content, "!tweetsearch ") -> tweetsearch_query(msg)
            String.starts_with?(msg.content, "!tweetsearch") ->
                Api.create_message(msg.channel_id, "Use **!tweetsearch <Termo>**.")
            #5
            String.starts_with?(msg.content, "!govstats ") -> govstats_query(msg)
            String.starts_with?(msg.content, "!govstats") ->
                Api.create_message(msg.channel_id, "Use **!govstats <Nome da cidade>**.")
            #6
            String.starts_with?(msg.content, "!generateqr ") -> qr_query(msg)
            String.starts_with?(msg.content, "!generateqr") ->
                Api.create_message(msg.channel_id, "Use **!generateqr <Link>**.")
            #7
            String.starts_with?(msg.content, "!lifeadvice") -> lifeadvice_query(msg)
            #8
            String.starts_with?(msg.content, "!startup") -> startup_query(msg)
            #9
            String.starts_with?(msg.content, "!pokemonin ") -> pokemonforcity_query(msg)
            String.starts_with?(msg.content, "!pokemonin") ->
                Api.create_message(msg.channel_id, "Use **!pokemonin <Cidade>**.")
            #10
            String.starts_with?(msg.content, "!dadjoke") -> dadjoke_query(msg)

            true -> :ignore
        end
    end

    def handle_event(_event) do
        :noop
    end

    #Funcao 1 -
    def eldenring_boss_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        bossName = Enum.fetch!(corpo, 1)
        resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")

        {:ok, map} = Poison.decode(resp.body)

        case map["success"] do
            true ->
                #obtendo chave de dicionario, dentro de lista obtida atraves de outra chave de dicionario.
                #Formato da API {"data":[{"name": "exemplo"}]}
                name = Enum.at(map["data"],0)["name"]
                description = Enum.at(map["data"],0)["description"]
                location = Enum.at(map["data"],0)["location"]
                image = Enum.at(map["data"],0)["image"]
                Api.create_message(msg.channel_id, "Name: #{name}
            Description: #{description}
            Location: #{location}
            #{image}")

            false ->
                Api.create_message(msg.channel_id, "Comando Invalido!")
        end
    end

    #Funcao 2 -
    def pokedex_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 2(pokedex), argumento: #{argumento}")
    end
    #Funcao 3 -
    def weather_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 3(tempo), argumento: #{argumento}")
    end
    #Funcao 4 -
    def tweetsearch_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 4(tweet Search), argumento: #{argumento}")
    end
    #Funcao 5 -
    def govstats_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 5(Gov Stats), argumento: #{argumento}")
    end
    #Funcao 6 -
    def qr_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 6(Generate QR), argumento: #{argumento}")
    end
    #Funcao 7 -
    def lifeadvice_query(msg) do
        corpo = msg.content
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 7(Life Advice)")
    end
    #Funcao 8 -
    def startup_query(msg) do
        corpo = msg.content
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 8(Start up Idea)")
    end
    #Funcao 9 -
    def pokemonforcity_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 9(pokemon fit for city), argumento: #{argumento}")
    end
    #Funcao 10 -
    def dadjoke_query(msg) do
        corpo = msg.content
        #resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 10(dadjoke)")
    end



end
