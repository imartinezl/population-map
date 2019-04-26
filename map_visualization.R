
source('data_preprocessing.R')

canary.lines <- function(g){
  list(
    ggplot2::geom_segment(x=3300, y=1580, xend=3850, yend=1580, size=0.3, colour="#404F4D"),
    ggplot2::geom_segment(x=3300, y=1350, xend=3300, yend=1580, size=0.3, colour="#404F4D")
  )
}
d %>% 
  dplyr::slice(1:20000) %>% 
  dplyr::mutate(empty = t1_1 == 0) %>% 
  ggplot2::ggplot()+
  ggplot2::geom_tile(ggplot2::aes(x=E,y=N, fill=empty), width=1, height=1)+
  ggplot2::geom_path(data=contour, ggplot2::aes(x=E,y=N,group=group), color="#404F4D", size=0.3) +
  canary.lines() +
  ggplot2::scale_fill_manual(guide=F,values=c('white','#35D68D'))+
  ggplot2::coord_equal()  #+
  #ggplot2::theme_void()
