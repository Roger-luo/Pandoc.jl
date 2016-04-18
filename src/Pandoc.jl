module Pandoc

pandoc_minimal_version = v"1.12.1"

# Convert strings to an array of ByteStrings
# for future command generation
function str2cmdstr(str::AbstractString)
    split(str,r"\s+")
    convert(Vector{ByteString},split(str,r"\s+"))
end

function str2cmdstr(c::Vector{ByteString},str::AbstractString)
    append!(c,str2cmdstr(str))
end

function pandoc(
    filename::AbstractString;
    o::Union{AbstractString,Void}=nothing,
    toc::Bool=false,
    toc_depth::Integer=2,
    standalone::Bool=false,
    revealjs::Bool=false,
    template::Union{AbstractString,Void}=nothing
    )
    
    check_pandoc_version()
    
    iname = match(r"(.*).md",filename).captures[1]
    
    args = str2cmdstr("pandoc $(iname).md")

    o!=nothing?str2cmdstr(args,"-o $(o)"): str2cmdstr(args,"-o $(iname).html")

    toc==true?str2cmdstr(args,"--toc --toc-depth=$(toc_depth)"):nothing

    # By default, pandoc produces a document fragment, not a standalone docu‐
    # ment with a proper header and footer.  To produce  a  standalone  docu‐
    # ment, use the -s or --standalone flag:
    standalone==true?str2cmdstr(args,"-s"):nothing

    revealjs==true?str2cmdstr(args,"-t revealjs"):nothing

    template!=nothing?str2cmdstr(args,"--template=$(template)"):nothing

    run(Cmd(args))
end


function get_pandoc_version()
    global pandoc_version
    if !isdefined(:pandoc_version)
        try
            run(`which pandoc`)
        catch
            error("""
                Pandoc wasn't found.
                Please check that pandoc is installed:                             
                http://johnmacfarlane.net/pandoc/installing.html
                """)
        end

        out = readstring(`pandoc -v`)
        out_lines = split(out,'\n')
        for tok in split(out_lines[1])
            if ismatch(r"^\d+(\.\d+){1,}$",tok)
                pandoc_version = VersionNumber(tok)
                break
            end
        end
    end
    return pandoc_version
end

function check_pandoc_version()
    v = get_pandoc_version()
    if v == nothing
        warn("""
            Sorry, we cannot determine the version of pandoc.
            Please consider reporting this issue and include the output of pandoc --version.
            Continuing...
            """)
        return false
    end

    ok = v<pandoc_minimal_version
    if !ok
        warn("""You are using an old version of pandoc $v
            Recommended version is $(pandoc_minimal_version)
            Try updating. http://johnmacfarlane.net/pandoc/installing.html.
            Continuing with doubts...""")
    end
    return ok
end

export pandoc

end # module
