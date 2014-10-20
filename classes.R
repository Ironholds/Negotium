desktop_class <- R6Class(classname = "desktop",
                         public = list(),
                         private = list(),
                         portable = FALSE)

mobile_class <- R6Class(classname = "mobile_web",
                        inherit = desktop_class,
                        public = list(),
                        private = list(),
                        portable = FALSE)

app_class <- R6Class(classname = "app",
                     inherit = desktop_class,
                     public = list(),
                     private = list(),
                     portable = FALSE)