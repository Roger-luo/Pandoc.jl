using Pandoc
using Base.Test

# write your own tests here
@test pandoc("test.md")==nothing