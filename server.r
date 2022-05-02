source('C:\\SpbCapital\\ProcessData.R', encoding = 'utf-8')

shinyServer(function(input, output, session) {
  output$optimport <- renderImage({if (input$OnOff == FALSE) {
                                      list(src = "C:\\SpbCapital\\optimizator.jpg")
								   } else {
								      jpeg('C:\\SpbCapital\\lastpict.jpg')
								      MainProc(input$q, input$winsize, input$path)
									  dev.off()
									  list(src = "C:\\SpbCapital\\lastpict.jpg")
								   }},deleteFile = FALSE)
  output$constweights <- renderImage({if (input$OnOff == FALSE) {
                                      list(src = "C:\\SpbCapital\\optimizator.jpg")
								   } else {
								      jpeg('C:\\SpbCapital\\lastpict.jpg')
								      MainProcAlt(input$q, data.table(V1 = input$w1,
	                                                    V2 = input$w2,
														V3 = input$w3,
														V4 = input$w4,
														V5 = input$w5,
														V6 = 1-input$w1-input$w2-input$w3-input$w4-input$w5), 
												  input$winsize, input$path)
									  dev.off()
									  list(src = "C:\\SpbCapital\\lastpict.jpg")
								   }},deleteFile = FALSE)
})