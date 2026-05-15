# Recursive JSON merge with directive objects.
# Patches are shaped like the target; objects containing reserved $-keys are
# interpreted as operations instead of data.

def K_UNSET:    "$PATCH$unset";
def K_REPLACE:  "$PATCH$replace";
def K_APPEND:   "$PATCH$append";
def K_AT:       "$PATCH$at";
def K_BY_FIELD: "$PATCH$byField";

# Patch DSL:
#
#   any target type:
#     {K_UNSET: <any>}                      delete the key from the enclosing object
#                                           (value of $unset is ignored)
#     {K_REPLACE: <any>}                    replace target wholesale
#
#   array target:
#     {K_APPEND: [...]}                     append items not already present
#     {K_AT: {"<idx>": <patch>, ...}}       patch elements by numeric index
#     {K_BY_FIELD: {"<field>":              patch elements where target[i][<field>] == "<value>"
#                   {"<value>": <patch>}}}  If multiple elements match, only the first is patched.
#
# Non directive values are replaced wholesale except for objects, which are recursively merged.
# Directive objects are identified by the presence of any reserved key.
# Non reserved keys in a directive object are ignored.
#
# Multiple ops in one object are applied in order: K_AT, K_BY_FIELD, K_APPEND.
# Example: {K_REPLACE: [1,2,3], K_APPEND: [4]}  ->  [1,2,3,4]
#
# K_UNSET and K_REPLACE are terminal: other ops in the same object are ignored when present.
# K_UNSET takes precedence over K_REPLACE.
#
# Operations not applicable to the target type are no-ops.
# E.g. K_APPEND on a non-array target is ignored.
#
# Usage:
#   jq -f merge.jq --slurpfile patch patch.json target.json

# Example:
#  Target: {"a": 1, "b": [1,2,3], "c": [{"id": "x", "v": 1}, {"id": "y", "v": 2}]}
#  Patch: {"a": {"$PATCH$unset": true}, "b": {"$PATCH$append": [2,4,1]},
#          "c": {"$PATCH$byField": {"id": {"x": {"v": 10}}}}},
# Result: {"b": [1,2,3,4], "c": [{"id": "x", "v": 10}, {"id": "y", "v": 2}]}


# Set-union concat: target order, then patch items not already present.
# Uses structural equality (- on arrays), so works for arrays of objects.
def append_unique(target; items):
  target + (items - target);

# Numeric keys of obj, sorted descending. Non-numeric keys are dropped.
# {"0": "a", "1e0": "b", "foo": "bar"}
# -> [{"idx": "1e0", "num_idx": 1}, {"idx": "0", "num_idx": 0}]
def reversed_numeric_keys(obj):
  obj
  | keys_unsorted
  | map({idx: ., num_idx: (tonumber?)})
  | map(select(.num_idx != null))
  | sort_by(.num_idx)
  | reverse;

# True if the object contains at least one reserved patch key.
def is_directive:
  (type == "object")
  and (. as $obj
       | any((K_UNSET, K_REPLACE, K_APPEND, K_AT, K_BY_FIELD);
             . as $k | $obj | has($k)));


def merge(target; patch):
  if patch | is_directive then
    # Bind ops; missing ops are null. Value of K_UNSET is ignored.
    (patch | has(K_UNSET))   as $is_unset
    | (patch[K_REPLACE])     as $replace_val
    | (patch[K_APPEND])      as $append_val
    | (patch[K_AT])          as $at_entries
    | (patch[K_BY_FIELD])    as $by_obj
    | if $is_unset then
        # Terminal. At root scope (which is here) this returns null.
        # object-merge branch handles actual key deletion via del.
        null

      # Check for existence of K_REPLACE because null and false a valid replacement values.
      elif (patch | has(K_REPLACE)) then
        # Terminal: ignore other ops.
        $replace_val

      else
        # K_AT: numeric-keyed sub-patches; reverse order so deletes don't change later indices.
        # If target isn't an array, skip patching.
        (if $at_entries != null and (target | type) == "array" then
             reduce (reversed_numeric_keys($at_entries)[]) as $kv (target;
               ($kv.num_idx) as $idx
               | ($at_entries[$kv.idx]) as $sub_patch
               | if $idx < 0 or $idx >= length then . # index out of bounds: ignore patch
                 elif ($sub_patch | type) == "object" and ($sub_patch | has(K_UNSET)) then del(.[$idx])
                 else .[$idx] = merge(.[$idx]; $sub_patch)
                 end)
           else target
           end) as $after_at

        # K_BY_FIELD: {field: {value: patch}}. Patch depending on field value.
        # Multiple fields are possible. Match via tostring so numeric ids work.
        | (if $by_obj != null and ($after_at | type) == "array" then
             reduce ($by_obj | to_entries[]) as $field_entry ($after_at;
               ($field_entry.key) as $field
               | ($field_entry.value) as $entries
               | reduce ($entries | keys_unsorted[]) as $kv (.;
                   ($entries[$kv]) as $sub_patch
                   # find first index that matches on the field
                   | (map((.[$field] | tostring) == $kv) | index(true)) as $idx
                   | if $idx == null then . # no match: ignore patch
                     elif ($sub_patch | type) == "object" and ($sub_patch | has(K_UNSET)) then del(.[$idx])
                     else .[$idx] = merge(.[$idx]; $sub_patch)
                     end))
           else $after_at
           end) as $after_by

        # K_APPEND: set-union concat.
        | if $append_val != null and ($after_by | type) == "array" then
            append_unique($after_by; $append_val)
          else $after_by
          end
      end

  elif (patch | type) == "object" and (target | type) == "object" then
    # Plain object on both sides: recursive merge.
    reduce (patch | keys_unsorted[]) as $k (target;
      (patch[$k]) as $sub_patch
      | if ($sub_patch | type) == "object" and ($sub_patch | has(K_UNSET)) then
          del(.[$k])
        elif (has($k) | not)
             and ($sub_patch | type) == "object"
             and ($sub_patch | is_directive)
             and ($sub_patch | has(K_REPLACE) | not) then
          # Directive addresses elements of $k, but $k is absent from target.
          # Skip rather than emit "$k": null. K_REPLACE can create from nothing.
          .
        else
          .[$k] = merge(.[$k]; $sub_patch)
        end)

  else
    # Scalar/array replacement, or object-vs-non-object mismatch.
    patch
  end;

# `--slurpfile` sets patch to array of parsed json
$patch[0] as $patch
| if $patch == null then . # No patch provided: identity.
  else merge(.; $patch)
  end
