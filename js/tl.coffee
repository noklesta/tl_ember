TL ?= Em.Namespace.create()

# Function for sorting numbers in ascending order. Provide as
# argument to the standard JavaScript sort method for arrays.
TL.numericalSort = (a, b) -> a - b