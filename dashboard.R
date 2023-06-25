# Install packages
#install.packages("RSQLite")
#install.packages("plotly")
#install.packages("quantmod")
#install.packages("shinydashboardPlus")
#install.packages("showtext")

# Load libraries
library(RSQLite)
library(ggplot2)
library(plotly)
library(shiny)
library(quantmod)
library(shinydashboard)
library(showtext)

# Set up font
showtext_auto()

# Connect to database
con <- dbConnect(RSQLite::SQLite(), dbname = "database.db")

# Fetch data from database
query <- "SELECT * FROM btc_price"
btc_data <- dbGetQuery(con, query)

# Disconnect from database
dbDisconnect(con)

# Prepare data
btc_prices <- data.frame(
  timestamp = as.POSIXct(btc_data$timestamp, origin = "1970-01-01"),
  open = btc_data$open,
  high = btc_data$high,
  low = btc_data$low,
  close = btc_data$close,
  volume = btc_data$volume
)

# Create candlestick chart
candlestick_chart <- plot_ly(data = btc_prices, type = "candlestick",
                             x = ~timestamp,
                             open = ~open,
                             high = ~high,
                             low = ~low,
                             close = ~close)

# Define UI
ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        text = "Graafik",
        icon = tags$i(style = "margin-right: 3px;", class = "fas fa-chart-line"),
        tabName = "graph"
      ),
      menuItem(
        text = "Teave",
        icon = tags$i(style = "margin-right: 6px;", class = "fas fa-file-alt"),
        tabName = "tab1"
      ),
      menuItem(
        text = "Protsess",
        icon = icon("sitemap"),
        tabName = "tab2"
      ),
      menuItem(
        text = "Seletuskiri",
        icon = tags$i(style = "margin-right: 6px;", class = "fas fa-file-alt"),
        tabName = "tab3"
      )
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML('
      /* logo */
      .skin-blue .main-header .logo {
        background-color: #009688;
      }
      /* navbar (rest of the header) */
      .skin-blue .main-header .navbar {
        background-color: #009688;
      }  
      /* logo when hovered */
      .skin-blue .main-header .logo:hover {
        background-color: #009688;
      }
      /* main sidebar */
      .skin-blue .main-sidebar {
        background-color: #FFCCBC;
        font-size: 18px;
        font-family: "Karla", sans-serif;
        line-height: 1.4;
      }

      /* active selected tab in the sidebarmenu */
      .skin-blue .main-sidebar .sidebar .sidebar-menu .active a {
        background-color: #FF5722;
      }

      /* other links in the sidebarmenu */
      .skin-blue .main-sidebar .sidebar .sidebar-menu a {
        background-color: #FFCCBC;
        color: #212121;
      }

      /* other links in the sidebarmenu when hovered */
      .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover {
        background-color: #FF5722;
      }
      /* toggle button when hovered  */                    
      .skin-blue .main-header .navbar .sidebar-toggle:hover {
        background-color: #009688;
      }

      /* body */
      .content-wrapper,
      .right-side {
        background-color: #BDBDBD;
      }

      .small-box.bg-yellow {
        background-color: #009688 !important;
        color: #000000 !important;
      }

      .small-box.bg-red {
        background-color: #FF5722 !important;
        color: #000000 !important;
      }

      p {
        font-size: 18px;
        font-family: "Karla", sans-serif;
        line-height: 1.4;
      }

      h1 {
        font-size: 56px;
        font-family: "Old Standard TT", serif;
        letter-spacing: -0.02em;
      }

      h2 {
        font-size: 40px;
        font-family: "Old Standard TT", serif;
        letter-spacing: -0.01em;
      }
    '))),
    tabItems(
      tabItem(
        tabName = "graph",
        fluidRow(
          column(
            width = 12,
            div(
              style = "margin-left: 46px; margin-top: 36px; margin-bottom: 0px; margin-right: 46px;",
              h1("BTC graafik tehniliseks analüüsiks")
            )
          )
        ),
        fluidRow(
        column (
          width = 12,
          div(
            style = "margin-left: 35px; margin-right: 17px;margin-top: 20px",
            column(
              width = 12,
              plotlyOutput("candlestickChart")
            )
          )
        )
      ),
        fluidRow(
          div(
            style = "display: flex;",
            column(
              width = 4,
              style = "background-color: #FFFFFF; border: 1px solid black; border-radius: 25px; margin-left: 64px;padding: 20px;margin-top: 15px;",
              checkboxGroupInput(
                inputId = "checkboxes",
                choices = c("EMA200", "EMA26", "EMA13"),
                label = "Exponential Moving Average", tags$style(".checkbox label {font-size: 18px; font-family: 'Karla', sans-serif;line-height: 1.4;}")
              )
            ),
            column(
              width = 4,
              style = "background-color: #FF5722; border: 1px solid black; border-radius: 25px; margin-left: 15px;margin-top: 15px; padding: 20px;",
              valueBoxOutput("Price")
            ),
            column(
              width = 4,
              style = "background-color: #009688; border: 1px solid black; border-radius: 25px; margin-left: 15px;margin-right: 46px; margin-top: 15px;padding: 20px;",
              valueBoxOutput("RSI")
            )
          )
        )
      ),
      tabItem(
        tabName = "tab1",
        fluidRow(
          tags$div(
            style = "margin-left: 46px;margin-top:36px;margin-bottom:0px; margin-right:46px ",
            tags$h1("Tehniline analüüs")
          ),
          tags$div(
            style = "margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Sissejuhatus")
          ),
          tags$div(
            style = "margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p("Dashboard on tehtud, et näitlikustada lihtsamaid võimalusi tehnilise analüüsi kasutamiseks kauplemise juures. Andmed saadakse Binance API-st ning kuvatakse graafikul. Graafikule saab lisada 
                   erinevaid tehnilise analüüsi indikaatoreid")
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Mõisted")
          ),
          tags$div(
            style = "margin-left: 46px; margin-bottom: 0px; margin-right: 46px",
            tags$p(
              tags$strong("Tehniline analüüs"), " - finantsvaldkonna analüüsimetoodika hindade ennustamiseks turuandmete (peamiselt hinna ja tehingute mahu) ajaloo uurimise ja töötlemise kaudu"
            )
          ),
          tags$div(
            style = "margin-left: 46px; margin-bottom: 0px; margin-right: 46px",
            tags$p(
              tags$strong("EMA"), " - eksponentsiaalne libisev kesmine. kasutatakse hindade silumiseks ning selle pealt on näha, kas praegune hind on ajalooliselt all või ülevalpool. Number EMA järel tähendab mitu päeva tagasi turgu analüüsitakse."
            )
          ),
          tags$div(
            style = " margin-left: 46px; margin-bottom: 0px; margin-right: 46px",
            tags$p(
              tags$strong("RSI 7"), " - Suhtelise tugevuse indeks. See mõõdab kauplemisinstrumendi tugevust võrreldes seda viimase 7 päevaga. RSI väärtus jääb alati 0 ja 100 vahel. Kui RSI on madal võib see näidata ostu kohta, kui kõrge,siis müügi kohta."
            )
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Kokkuvõte")
          ),
          tags$div(
            style = "margin-left: 46px;margin-top:10px;margin-bottom:0px; margin-right:46px ",
            tags$p("Kogu projekt on tehtud näitlikustamaks tehnilist analüüsi kui ühte võimalust kauplemiseks. Kindlasti ei tohi nende andmete põhjal mingisuguseid tehinguid teha.")
          ),
          tags$div(
            style = " margin-bottom: 20px; margin-left:46px; margin-right:46px;display: flex; justify-content: center",
            tags$img(src = "krupto_kurbus.png", style = "max-width: 100%; height: auto;")
          )
        )
      ),
      tabItem(
        tabName = "tab2",
        fluidRow(
          tags$div(
            style = "margin-left: 46px;margin-top:36px;margin-bottom:0px; margin-right:46px ",
            tags$h1("Töö protsess (ELT)")
          ),
          tags$div(
            style = " margin-bottom: 20px;margin-top:0px; margin-left:46px; margin-right:46px;display: flex; justify-content: center",
            tags$img(src = "work_process_1.png", style = "max-width: 100%; height: auto;")
          )
        )
      ),
      tabItem(
        tabName = "tab3",
        fluidRow(
          tags$div(
            style = " margin-left: 46px;margin-top:36px;margin-bottom:0px; margin-right:46px ",
            tags$h1("Seletuskiri")
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("CVI")
          ),
          tags$div(
            style = " margin-left:46px; margin-right:46px;display: flex; justify-content: center",
            tags$img(src = "CVI.png", style = "max-width: 100%; height: auto;")
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Idee")
          ),
          tags$div(
            style = " margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p("Projekti ideed otsides sattusin samal ajal lugema Alexander Elderi raamatut \"Borsikauplemine kui elatusallikas\" ja mõtlesin, et võiks teha dashboardi, mis lihtsalt osa sellest raamatust näitlikustaks. Väga suurt praktilist väärtust projektil ei ole, sest internet on täis tööriistu, mis seda üalju paremini teevad, aga projekt minu jaoks oli väga põnev. ")
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Disain")
          ),
          tags$div(
            style = " margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p("Dashboardi disainides olin ma suhteliselt hädas CSS-i osa kirjutamisega, sest enne projekti puudus sellega kogemus. Tänu sellele jäid osad asjad teistmoodi kui oleksin soovinud. Värvid valisin selle järgi, mis mulle meeldivad, palleti sain https://www.materialpalette.com/ kasutades. Värvid on samad kogu töös . Igal pool kus on tekst, kontrollisin, et kontrastsus oleks hea. Graafiku hoidsin võimalikult minimalistlikuna. Graafikul värvid valisin erinevad, et kogu infot oleks võimalik lugeda.
                  ")
          ),
          tags$div(
            style = "margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p(tags$strong(" Pilt numbriga")," on mõeldud teksti illustreerimiseks. Pilku peaks püüdma pildi vasakpoolne osa, tekstile alla paremale võiks inimese fookus jõuda kõige viimasena. ")
          ),
          tags$div(
            style = "margin-left: 46px; margin-bottom: 0px; margin-right: 46px",
            tags$p(
              tags$strong("Skeem"), "on tehtud lihtne ning kujutab üldiseid etappe ning milliseid tööriistu kasutades etapid saavutati. Värvid on võetud nii, et alguses oleks heledam ja lõpus tumedam, viimane värv on saadud paletist. Ikoonid sain nii Canva-st kui otsisin internetist, et stiil oleks sarnane. "
            )
          ),
          tags$div(
            style = " margin-left: 46px;margin-top:0px;margin-bottom:0px; margin-right:46px ",
            tags$h2("Kokkuvõte")
          ),
          tags$div(
            style = " margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p("Projektiga saan vaikselt edasi tegeleda. Natukene oleks vaja CSS-i õpida ning siis teha eraldi style sheet, kuhu saan luua klassid ja id-d, et stiili muutmine R-is lihtsam oleks. Samuti on mõte andmetehnika osas
                   automatiseerida API-st andmete küsimise protsess ning lisada dashboardile palju erinevaid krüptorahasid.")
          ),
          tags$div(
            style = "margin-left: 46px;margin-bottom:0px; margin-right:46px ",
            tags$p("Projektiga jäin ise rahule, sest sain targemaks ning hea kogemuse, kuidas dashboardi R-iga luua on.")
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$candlestickChart <- renderPlotly({
    
    # Calculate EMA200
    btc_prices$EMA200 <- EMA(btc_prices$close, n = 200)
    # Calculate EMA26
    btc_prices$EMA26 <- EMA(btc_prices$close, n = 26)
    # Calculate EMA13
    btc_prices$EMA13 <- EMA(btc_prices$close, n = 13)
    
    candlestick_chart <- plot_ly(
      data = btc_prices,
      type = "candlestick",
      x = ~timestamp,
      open = ~open,
      high = ~high,
      low = ~low,
      close = ~close
    )
    
    if ("EMA200" %in% input$checkboxes) {
      # Add EMA200 line to the chart
      candlestick_chart <- candlestick_chart %>%
        add_lines(
          x = ~timestamp,
          y = ~EMA200,
          name = "EMA200",
          showlegend = FALSE,
          hoverinfo = "name",
          line = list(color = "orange")
        )
    }
    if ("EMA26" %in% input$checkboxes) {
      # Add EMA26 line to the chart
      candlestick_chart <- candlestick_chart %>%
        add_lines(
          x = ~timestamp,
          y = ~EMA26,
          name = "EMA26",
          showlegend = FALSE,
          hoverinfo = "name",
          line = list(color = "darkgreen")
        )
    }
    if ("EMA13" %in% input$checkboxes) {
      # Add EMA13 line to the chart
      candlestick_chart <- candlestick_chart %>%
        add_lines(
          x = ~timestamp,
          y = ~EMA13,
          name = "EMA13",
          showlegend = FALSE,
          hoverinfo = "name",
          line = list(color = "blue")
        )
    }
    candlestick_chart %>%
      layout(yaxis = list(title = "", fixedrange = FALSE), xaxis = list(title = ""))
  })
  
  output$Price <- renderValueBox({
    last_row <- tail(btc_prices, n = 1)
    closing_price <- last_row$close
    
    valueBox(
      value = closing_price,
      subtitle = tags$p(
        "PRICE",
        style = "font-size: 18px; font-family: 'Karla', sans-serif; line-height: 1.4;"
      ),
      color = "red"
    )
  })
  
  output$RSI <- renderValueBox({
    rsi <- RSI(btc_prices$close, n = 7)
    last_rsi <- tail(rsi, n = 1)
    valueBox(
      value = round(last_rsi, digits = 2),
      subtitle = tags$p(
        "RSI 7",
        style = "font-size: 18px; font-family: 'Karla', sans-serif; line-height: 1.4;"
      ),
      color = "yellow",
      width = "100%"
    )
  })
}

shinyApp(ui, server)