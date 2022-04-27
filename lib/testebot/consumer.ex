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
5- !translate: Traduz qualquer texto fornecido em ingles para portugues, atraves da google translate API
6- !generateqr link: gera qr code copiável para qualquer link fornecido.
7- !lifeadvice: Gera conselho aleatório sobre a vida chamado por Advice Slip
8- !startup: Gera uma definição de StartUp
9- !pokemonin cidade: Acessa a API Openweather, obtém o clima da cidade fornecida e retorna uma lista de 10 pokemons (Acessando a pokeAPI) adequados para aquela cidade
10- !dadjoke: gera dad joke anonima

                ")

            #1 DONE
            String.starts_with?(msg.content, "!erboss ") -> eldenring_boss_query(msg)
            String.starts_with?(msg.content, "!erboss") ->
                Api.create_message(msg.channel_id, "Use **!erboss <Nome>**.")
            #2 DONE
            String.starts_with?(msg.content, "!pokedex ") -> pokedex_query(msg)
            String.starts_with?(msg.content, "!pokedex") ->
                Api.create_message(msg.channel_id, "Use **!pokedex <Nome>**.")

            #3 DONE
            String.starts_with?(msg.content, "!weather ") -> weather_query(msg)
            String.starts_with?(msg.content, "!weather") ->
                Api.create_message(msg.channel_id, "Use **!weather <Nome da cidade>**.")
            #4
            String.starts_with?(msg.content, "!tweetsearch ") -> tweetsearch_query(msg)
            String.starts_with?(msg.content, "!tweetsearch") ->
                Api.create_message(msg.channel_id, "Use **!tweetsearch <Termo>**.")
            #5 DONE
            String.starts_with?(msg.content, "!translate ") -> translate_query(msg)
            String.starts_with?(msg.content, "!translate") ->
                Api.create_message(msg.channel_id, "Use **!translate <Texto a ser traduzido do ingles para portugues>**.")
            #6 DONE
            String.starts_with?(msg.content, "!generateqr ") -> qr_query(msg)
            String.starts_with?(msg.content, "!generateqr") ->
                Api.create_message(msg.channel_id, "Use **!generateqr <Link>**.")
            #7 DONE
            String.equivalent?(msg.content, "!lifeadvice") -> lifeadvice_query(msg)
            #8 DONE
            String.equivalent?(msg.content, "!startup") -> startup_query(msg)
            #9
            String.starts_with?(msg.content, "!pokemonin ") -> pokemonforcity_query(msg)
            String.starts_with?(msg.content, "!pokemonin") ->
                Api.create_message(msg.channel_id, "Use **!pokemonin <Cidade>**.")
            #10 DONE
            String.equivalent?(msg.content, "!dadjoke") -> dadjoke_query(msg)

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
        argumento = Enum.fetch!(corpo, 1) #o nome ou numero do pokemon
        resp = HTTPoison.get!("https://pokeapi.co/api/v2/pokemon/#{argumento}")

        {status, map} = Poison.decode(resp.body)

        case status do
        :ok ->
            meunome = map["name"]
            foundTypes = Enum.map(map["types"], fn val ->
                val["type"]["name"]
             end)
            foundAbilities =  Enum.map(map["abilities"], fn val ->
                val["ability"]["name"]
             end)
            foundStats = Enum.map(map["stats"], fn val ->
                Enum.join([val["stat"]["name"], inspect(val["base_stat"], charlists: :as_lists)], ": ")
            end)

            officialArt = map["sprites"]["other"]["official-artwork"]["front_default"]

            Api.create_message(msg.channel_id, "
            **Nome:** #{meunome}
            **Tipo(s):** #{Enum.join(foundTypes, ", ")}
            **Abilidade(s):** #{Enum.join(foundAbilities, ", ")}
            **Status Base:** #{Enum.join(foundStats, ", ")}
            **Imagem:** #{officialArt}
            ")
        :error ->
            Api.create_message(msg.channel_id, "Erro: Pokemon #{argumento} nao encontrado.")
        end
    end

    #Funcao 3 -
    def weather_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)

        resp = HTTPoison.get!("http://api.openweathermap.org/data/2.5/weather?q=#{argumento}&appid=#{
            Application.get_env(:nostrum, :openWeatherToken)}")
        {:ok, map} = Poison.decode(resp.body)

        case map["cod"] do
          200 ->
            #teste traducao
            clima = portufy("#{Enum.at(map["weather"], 0)["description"]}")
            Api.create_message(msg.channel_id, "Funcao 3 - Relatorio do tempo
          Cidade: #{map["name"]}, #{map["sys"]["country"]}
          Temperatura: #{ Float.round(map["main"]["temp"] - 273.15, 2) } C°
          Clima: #{clima}
          Humidade: #{map["main"]["humidity"]}%
          ")
          _ -> Api.create_message(msg.channel_id, "Houve um erro na requisicao.")
        end


    end
    #Funcao 4 -
    def tweetsearch_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        #resp = HTTPoison.get!("http://api.openweathermap.org/data/2.5/weather?q=#{argumento}&appid=#{}")
        #{:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 4(tweet Search), argumento: #{argumento}")
    end
    #Funcao 5 -
    def translate_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)


        Api.create_message(msg.channel_id, "Tradução (pt-br): #{portufy(argumento)}")
    end
    #SubFuncao 5 - Responsavel por traduzir uma string fornecida.
    #target = codigo para linguagem a ser obtida
    #source = codigo para linguagem origem do texto a ser traduzido
    def translate(arg,target,source) do
        url = "https://google-translate1.p.rapidapi.com/language/translate/v2"

        payload = "q=#{arg}&target=#{target}&source=#{source}"
        headers = [
            "content-type": "application/x-www-form-urlencoded",
            "Accept-Encoding": "application/gzip",
            "X-RapidAPI-Host": "google-translate1.p.rapidapi.com",
            "X-RapidAPI-Key": Application.fetch_env!(:nostrum, :XRapidAPIKey)
        ]

        resp = HTTPoison.post!(url, payload, headers)
        {:ok, map} = Poison.decode(resp.body)
        #return
        Enum.at(map["data"]["translations"], 0)["translatedText"]
    end

    #traduz estritamente do ingles para o portugues
    def portufy(arg) do
      translate(arg,"pt","en")
    end

    #Funcao 6 - QR code gerado como imagem png pela api. logo, nao se foi necessario realizar um get pelo httppoison.
    def qr_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        argumento = Enum.fetch!(corpo, 1)
        Api.create_message(msg.channel_id,"https://api.qrserver.com/v1/create-qr-code/?size=256x256&data=#{argumento}")
    end
    #Funcao 7 -
    def lifeadvice_query(msg) do
        resp = HTTPoison.get!("https://api.adviceslip.com/advice")
        {:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Life Advice: #{map["slip"]["advice"]}")
    end
    #Funcao 8 -
    #API retorna texto cru, nao ha necessidade de trabalhar os dados.
    def startup_query(msg) do
        resp = HTTPoison.get!("http://itsthisforthat.com/api.php?text")
        Api.create_message(msg.channel_id, "Funcao 8 (Start up Idea):  #{resp.body}")
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
    #API requer header "Accept" de acordo com o retorno desejado.
    def dadjoke_query(msg) do
        headers = ["Accept": "application/json"]
        resp = HTTPoison.get!("https://icanhazdadjoke.com/", headers)
        {:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Funcao 10(dadjoke): #{map["joke"]}")
    end



end
