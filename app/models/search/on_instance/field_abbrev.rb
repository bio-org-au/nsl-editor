#   Copyright 2015 Australian National Botanic Gardens
#
#   This file is part of the NSL Editor.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Field abbreviations available for building predicates
class Search::OnInstance::FieldAbbrev
  ABBREVS = {
    "n:" => "name:",
    "a:" => "abbrev:",
    "adnot:" => "comments:",
    "adnot-by:" => "comments-by:",
    "it:" => "type:",
    "note:" => "notes:",
    "note-exact:" => "notes-exact:",
    "p:" => "page:",
    "pq:" => "page-qualifier:",
    "instance-type:" => "type:",
    "t:" => "type:",
    "ty:" => "type:",
    "ref-year:" => "year:",
    "y:" => "year:",
  }
end