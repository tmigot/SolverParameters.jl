export AbstractParameterSet
export value, domain, name, names!, set_value!, update!, lower_bounds, upper_bounds, set_names!
export length_num, values_num!, update_num!

""" `AbstractParameterSet`
An abstract type that represents a set of multiple parameters.

Example:
```julia
  mutable struct MySolverParameterSet <: AbstractParameterSet
    η₁::Parameter(1.0e-5, RealInterval(0, 1; lower_open=true, upper_open=false))
  end
```
"""
abstract type AbstractParameterSet end

"""Returns the number of parameters in a parameter set."""
function length(::T) where {T <: AbstractParameterSet}
  return length(fieldnames(T))
end

"""Returns the number of numerical parameters in a parameter set."""
function length_num(parameter_set::T) where {T <: AbstractParameterSet}
  k = 0
  for param_name in fieldnames(T)
    p = getfield(parameter_set, param_name)
    if !(typeof(p.domain) <: CategoricalDomain)
      k += 1
    end
  end
  return k
end

"""Returns the name of the parameters in a parameter set."""
function names(parameter_set::T) where {T <: AbstractParameterSet}
  n = Vector{String}(undef, length(parameter_set))
  return names!(parameter_set, n)
end

"""Returns the name of the parameters in a parameter set in place."""
function names!(parameter_set::T, vals::Vector{String}) where {T <: AbstractParameterSet}
  length(parameter_set) == length(vals) || error(
    "Error: 'vals' should have length $(length(parameter_set)), but has length $(length(vals)).",
  )
  for (i, param_name) in enumerate(fieldnames(T))
    p = getfield(parameter_set, param_name)
    vals[i] = name(p)
  end
  return vals
end

"""Set names of parameters to their fieldnames."""
function set_names!(parameter_set::T) where {T <: AbstractParameterSet}
  for param_name in fieldnames(T)
    p = getfield(parameter_set, param_name)
    p.name = string(param_name)
  end
end

"""Returns current values of each parameter in a parameter set."""
function values(parameter_set::T) where {T <: AbstractParameterSet}
  vals = Vector{Any}(undef, length(parameter_set))
  return values!(parameter_set, vals)
end

"""Returns current values of each parameter in a parameter set in place."""
function values!(parameter_set::T, vals::AbstractVector) where {T <: AbstractParameterSet}
  length(parameter_set) == length(vals) || error(
    "Error: 'vals' should have length $(length(parameter_set)), but has length $(length(vals)).",
  )
  for (i, param_name) in enumerate(fieldnames(T))
    p = getfield(parameter_set, param_name)
    vals[i] = value(p)
  end
  return vals
end

"""Returns current values of each numerical parameter in a parameter set in place."""
function values_num!(parameter_set::T, vals::AbstractVector{S}) where {T <: AbstractParameterSet, S}
  len = length_num(parameter_set)
  len == length(vals) ||
    error("Error: 'vals' should have length $(len), but has length $(length(vals)).")
  i = 0
  for param_name in fieldnames(T)
    p = getfield(parameter_set, param_name)
    if !(typeof(p.domain) <: CategoricalDomain)
      i += 1
      vals[i] = S(value(p))
    end
  end
  return vals
end

"""Updates the values of a parameter set by the values given in a vector of values."""
function update!(parameter_set::T, new_values::AbstractVector) where {T <: AbstractParameterSet}
  length(parameter_set) == length(new_values) || error(
    "Error: 'new_values' should have length $(length(parameter_set)), but has length $(length(new_values)).",
  )
  for (i, param_name) in enumerate(fieldnames(T))
    p = getfield(parameter_set, param_name)
    converted_value = convert(p, new_values[i])
    set_value!(p, converted_value)
  end
end

"""Updates the numerical values of a parameter set by the values given in a vector of values."""
function update_num!(parameter_set::T, new_values::AbstractVector) where {T <: AbstractParameterSet}
  len = length_num(parameter_set)
  len == length(new_values) ||
    error("Error: 'new_values' should have length $(len), but has length $(length(new_values)).")
  i = 0
  for param_name in fieldnames(T)
    p = getfield(parameter_set, param_name)
    if !(typeof(p.domain) <: CategoricalDomain)
      i += 1
      converted_value = convert(p, new_values[i])
      set_value!(p, converted_value)
    end
  end
  return new_values
end

"""Returns lower bounds of each parameter in a parameter set."""
function lower_bounds(parameter_set::T) where {T <: AbstractParameterSet}
  lower_bounds = Vector{Any}(undef, length(parameter_set))
  return lower_bounds!(parameter_set, lower_bounds)
end

"""Returns lower bounds of each parameter in a parameter set in place."""
function lower_bounds!(parameter_set::T, vals::AbstractVector) where {T <: AbstractParameterSet}
  length(parameter_set) == length(vals) || error(
    "Error: 'vals' should have length $(length(parameter_set)), but has length $(length(vals)).",
  )
  for (i, param_name) in enumerate(fieldnames(T))
    p = getfield(parameter_set, param_name)
    d = domain(p)
    vals[i] = lower(d)
  end
  return vals
end

"""Function that returns upper bounds of each parameter in a parameter set."""
function upper_bounds(parameter_set::T) where {T <: AbstractParameterSet}
  upper_bounds = Vector{Any}(undef, length(parameter_set))
  return upper_bounds!(parameter_set, upper_bounds)
end

"""Returns upper bounds of each parameter in a parameter set in place."""
function upper_bounds!(parameter_set::T, vals::AbstractVector) where {T <: AbstractParameterSet}
  length(parameter_set) == length(vals) || error(
    "Error: 'vals' should have length $(length(parameter_set)), but has length $(length(vals)).",
  )
  for (i, param_name) in enumerate(fieldnames(T))
    p = getfield(parameter_set, param_name)
    d = domain(p)
    vals[i] = upper(d)
  end
  return vals
end