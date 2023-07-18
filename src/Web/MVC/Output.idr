module Web.MVC.Output

import JS
import Text.CSS
import Text.HTML
import Web.Dom
import Web.Html
import public Text.HTML.Ref
import public Text.HTML.Tag

%default total

||| DOM type associacte with an ElemRef
public export
0 ElemType : Ref t -> Type
ElemType (Id _)   = HTMLElement
ElemType Body     = HTMLElement
ElemType Document = Document
ElemType Window   = Window

--------------------------------------------------------------------------------
--          Accessing and Updating Nodes
--------------------------------------------------------------------------------

||| Tries to retrieve an element of the given type by looking
||| up its ID in the DOM. Unlike `getElementById`, this will throw
||| an exception in the `JSIO` monad if the element is not found
||| or can't be safely cast to the desired type.
export
strictGetElementById : SafeCast t => (tag,id : String) -> JSIO t
strictGetElementById tag id = do
  Nothing <- castElementById t id | Just t => pure t
  liftJSIO $ throwError $
    Caught "Web.MVC.Reactimate.strictGetElementById: Could not find \{tag} with id \{id}"

||| Tries to retrieve a HTMLElement by looking
||| up its ID in the DOM. Unlike `getElementById`, this will throw
||| an exception in the `JSIO` monad if the element is not found
||| or can't be safely cast to the desired type.
export %inline
strictGetHTMLElementById : (tag,id : String) -> JSIO HTMLElement
strictGetHTMLElementById = strictGetElementById

||| Tries to retrieve an element of the given type by looking
||| up its ID in the DOM. Unlike `getElementById`, this will throw
||| an exception in the `JSIO` monad if the element is not found
||| or can't be safely cast to the desired type.
export
getElementByRef : (r : Ref t) -> JSIO (ElemType r)
getElementByRef (Id {tag} id) = strictGetElementById tag id
getElementByRef Body          = body
getElementByRef Document      = document
getElementByRef Window        = window

err : String
err = "Web.MVC.Reactimate.castElementByRef"

||| Tries to retrieve an element of the given type by looking
||| up its ID in the DOM. Unlike `getElementById`, this will throw
||| an exception in the `JSIO` monad if the element is not found
||| or can't be safely cast to the desired type.
export
castElementByRef : {0 x : k} -> SafeCast t => Ref x -> JSIO t
castElementByRef (Id {tag} id) = strictGetElementById tag id
castElementByRef Body          = body >>= tryCast err
castElementByRef Document      = document >>= tryCast err
castElementByRef Window        = window >>= tryCast err

setVM : Ref t -> ValidityTag t -> String -> JSIO ()
setVM r SVButton s   = castElementByRef r >>= \x => HTMLButtonElement.setCustomValidity x s
setVM r SVFieldSet s = castElementByRef r >>= \x => HTMLFieldSetElement.setCustomValidity x s
setVM r SVInput s    = castElementByRef r >>= \x => HTMLInputElement.setCustomValidity x s
setVM r SVObject s   = castElementByRef r >>= \x => HTMLObjectElement.setCustomValidity x s
setVM r SVOutput s   = castElementByRef r >>= \x => HTMLOutputElement.setCustomValidity x s
setVM r SVSelect s   = castElementByRef r >>= \x => HTMLSelectElement.setCustomValidity x s
setVM r SVTextArea s = castElementByRef r >>= \x => HTMLTextAreaElement.setCustomValidity x s

setVal : Ref t -> ValueTag t -> String -> JSIO ()
setVal r VButton s   = castElementByRef r >>= (HTMLButtonElement.value =. s)
setVal r VData s     = castElementByRef r >>= (HTMLDataElement.value =. s)
setVal r VInput s    = castElementByRef r >>= (HTMLInputElement.value =. s)
setVal r VOption s   = castElementByRef r >>= (HTMLOptionElement.value =. s)
setVal r VOutput s   = castElementByRef r >>= (HTMLOutputElement.value =. s)
setVal r VParam s    = castElementByRef r >>= (HTMLParamElement.value =. s)
setVal r VSelect s   = castElementByRef r >>= (HTMLSelectElement.value =. s)
setVal r VTextArea s = castElementByRef r >>= (HTMLTextAreaElement.value =. s)

export
setValidityMessage : Ref t -> ValidityTag t => String -> JSIO ()
setValidityMessage r = setVM r %search

export
setValue : Ref t -> ValueTag t => String -> JSIO ()
setValue r = setVal r %search

--------------------------------------------------------------------------------
--          DOM Updates
--------------------------------------------------------------------------------

nodeList : DocumentFragment -> List (HSum [Node,String])
nodeList df = [inject $ df :> Node]

||| Replaces all children of the given node with a new document fragment.
export %inline
replaceChildren : Element -> DocumentFragment -> JSIO ()
replaceChildren elem = replaceChildren elem . nodeList

||| Appends the given document fragment to a DOM element's children
export %inline
appendDF : Element -> DocumentFragment -> JSIO ()
appendDF elem = append elem . nodeList

||| Prepends the given document fragment to a DOM element's children
export %inline
prependDF : Element -> DocumentFragment -> JSIO ()
prependDF elem = prepend elem . nodeList

||| Inserts the given document fragment after a DOM element.
export %inline
afterDF : Element -> DocumentFragment -> JSIO ()
afterDF elem = after elem . nodeList

||| Inserts the given document fragment before a DOM element.
export %inline
beforeDF : Element -> DocumentFragment -> JSIO ()
beforeDF elem = before elem . nodeList

||| Inserts the given document fragment before a DOM element.
export %inline
replaceDF : Element -> DocumentFragment -> JSIO ()
replaceDF elem = replaceWith elem . nodeList
