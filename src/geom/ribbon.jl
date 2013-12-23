
# Ribbon geometry is like a fill between two ribbons
immutable RibbonGeometry <: Gadfly.GeometryElement
    default_statistic::Gadfly.StatisticElement

    # Do not reorder points along the x-axis.
    preserve_order::Bool

    function RibbonGeometry(default_statistic=Gadfly.Stat.identity();
                          preserve_order=false)
        new(default_statistic, preserve_order)
    end
end


const ribbon = RibbonGeometry


# Maybe use this to make like a geom_area
#function density()
#    RibbonGeometry(Gadfly.Stat.density())
#end
#
#
#function smooth(; smoothing::Float64=0.75)
#    RibbonGeometry(Gadfly.Stat.smooth(smoothing=smoothing))
#end
#
#
#function default_statistic(geom::RibbonGeometry)
#    geom.default_statistic
#end


function element_aesthetics(::RibbonGeometry)
    [:x, :ymin, :ymax, :color, :alpha, :fill, :size] # , :linetype]
end


# Render ribbon geometry.
#
# Args:
#   geom: ribbon geometry.
#   theme: the plot's theme.
#   aes: aesthetics.
#
# Returns:
#   A compose Form.
#
function render(geom::RibbonGeometry, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
    #Gadfly.assert_aesthetics_defined("Geom.ribbon", aes, :x, :ymin, :ymax)
    #Gadfly.assert_aesthetics_equal_length("Geom.ribbon", aes,
    #                                      element_aesthetics(geom)...)

    default_aes = Gadfly.Aesthetics()
    default_aes.color = PooledDataArray(ColorValue[theme.default_color])
    aes = inherit(aes, default_aes)

    #if length(aes.color) == 1
        ymin_points = {(x, ymin) for (x, ymin) in zip(aes.x, aes.ymin)}
        ymax_points = {(x, ymax) for (x, ymax) in zip(aes.x, aes.ymax)}
        #if !geom.preserve_order
            sort!(ymin_points)
            sort!(ymax_points, rev=true)
        #end
        form = compose((polygon(ymin_points..., ymax_points...)),
                       stroke(aes.color[1]),
                       fill(aes.color[1]),
                       svgid(Gadfly.unique_svg_id()),
                       svgclass("geometry"))

    #else
    #    # group points by color
    #    points = Dict{ColorValue, Array{(Float64, Float64),1}}()
    #    for (x, y, c) in zip(aes.x, aes.y, cycle(aes.color))
    #        if !haskey(points, c)
    #            points[c] = Array((Float64, Float64),0)
    #        end
    #        push!(points[c], (x, y))
    #    end

    #    forms = Array(Any, length(points))
    #    for (i, (c, c_points)) in enumerate(points)
    #        if !geom.preserve_order
    #            sort!(c_points)
    #        end
    #        forms[i] =
    #            compose(ribbons({(x, y) for (x, y) in c_points}...),
    #                    stroke(c),
    #                    svgclass(@sprintf("geometry color_%s",
    #                                      escape_id(aes.color_label([c])[1]))))
    #    end
    #    form = combine(forms...)
    #end

    compose(form, fill(nothing), linewidth(theme.line_width))
end


