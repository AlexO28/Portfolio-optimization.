shinyUI(fluidPage(
	# Application title
	headerPanel("Оптимизатор"),

	sidebarPanel(width = 15,
		fluidRow(
                  column(2,
                    checkboxInput("OnOff", label = "Вкл.", value = FALSE),
                    numericInput("q", label = "Уровень риска", value = 0.5),
					textInput("path", label = "Путь к данным", value = 'C:\\SpbCapital\\data.csv'),
					numericInput("winsize", label = "Размер окна", value = 30)
				  ),
				  column(2,
                    numericInput("w1", label = "Вес 1-го актива", value = 1),
                    numericInput("w2", label = "Вес 2-го актива", value = 0),
                    numericInput("w3", label = "Вес 3-го актива", value = 0)
				  ),
				  column(2,
                    numericInput("w4", label = "Вес 4-го актива", value = 0),
                    numericInput("w5", label = "Вес 5-го актива", value = 0)
				  )				  
		)
    ),
	mainPanel(
          tabsetPanel(
             tabPanel("Оптимальный портфель",
               imageOutput("optimport")
             ),
             tabPanel("Постоянные веса", 
               imageOutput("constweights")
             )
	) 	  
	)
))
