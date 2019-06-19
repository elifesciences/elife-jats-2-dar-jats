declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $inputfile as xs:string+ external;
(: declare variable $outputfile as xs:string+ external; :)
(:
Assumes that the local instance of Texture is running from files in the following directory '/Users/fredatherden/Documents/GitHub/texture/data/kitchen-sink'.

This currently runs on one file (currently 42955 with a <body>), bt could be adjusted to run/output numerous files with ease/processing power.
 :)

for $x in doc(concat('../', $inputfile))
let $y := 
copy $copy := $x
modify(
  for $a in $copy//*:sub-article
  return delete node $a,
  
  for $y in $copy//*:back/*:ack
  return (delete node $y,
          insert node <sec sec-type="acknowledgments">{$y/*}</sec> as last into $y/preceding::*:body),
  
  for $z in $copy//*:article-meta/*:author-notes
  return  delete node $z,
  
  for $s in $copy//*:sec[@sec-type="additional-information"]/*:fn-group
  return delete node $s,
  
  for $s in $copy//*:back/*:fn-group
  return delete node $s,
  
  for $x in $copy//*:front//*:xref[@ref-type="fn"]
  return delete node $x,
    
  for $e in $copy//*:object-id
  return delete node $e,
  
  for $d in $copy//*:funding-group/*:funding-statement
  return delete node $d,
  
  for $t in $copy//*:kwd-group/*:title
  return delete node $t,
  
  for $r in $copy//*:ref-list[*:title = 'Acknowledgements']
  return delete node $r,
    
  for $f in $copy//*:collab[not(descendant::*)]
  return delete node $f,
  
   for $x in  $copy//*:article-meta
  let $count := count($x/contrib-group[@content-type="section"])
  return if ($count > 1) then 
    (insert node <contrib-group content-type="section">{for $c in $x/*:contrib-group[@content-type="section"] return $c/*}</contrib-group> after $x/*:contrib-group[not(@*)],
     for $c in $x/*:contrib-group[@content-type="section"] return delete node $c)
  else (),
  
for $x in $copy//*:supplementary-material
let $m := $x/*:media
let $ms := $m/@mime-subtype
let $mt := $m/@mimetype
let $xl := $m/@xlink:href
return (insert node attribute mime-subtype {$ms} into $x,
        insert node attribute mimetype {$mt} into $x,
        insert node attribute xlink:href {$xl} into $x,
        delete node $m), 
 
  for $f in $copy//*:related-article
  return delete node $f,
  
  for $f in $copy//*:related-object
  return delete node $f,
  
  for $x in  $copy//*:p//*:disp-formula
  return 
  if ($x/ancestor::caption) then delete node $x
  else if ($x/ancestor::list/ancestor::*:p) then 
          (insert node $x after $x/ancestor::*:list/ancestor::*:p[position() = last()],
          delete node $x)
  else if ($x/ancestor::list) then 
          (insert node $x after $x/ancestor::*:list[position() = last()],
          delete node $x)
  else (insert node $x after $x/ancestor::*:p[position() = last()],
          delete node $x),
  
  for $o in $copy//*:abstract[@abstract-type="executive-summary"]
  return delete node $o,
  
  for $x in $copy//*:element-citation//*:xref
  return delete node $x,
  
  for $x in $copy//*:fig/*:attrib
  return delete node $x,
  
  for $x in $copy//*:body
  return 
  if ($x/following-sibling::*:back) then ()
  else insert node <back/> after $x,
  
  for $i in  $copy//*:table-wrap[count(descendant::*:table)>1]
  return (delete node $i,
  for $t in $i//*:table
          let $count := count($i/descendant::*:table)
          let $pos := $count - count($t/following-sibling::*:table)
        return
          if ($pos = 1) then insert node <table-wrap id="{$i/@id}">{$i/*:label}{$t}</table-wrap> after $i
          else insert node <table-wrap id="{($i/@id || '.'|| $pos)}">{$t}</table-wrap>  after $i),
          
  for $x in $copy//*:fig/*:graphic
  let $count := count($x/ancestor::*:article//*:fig)
  let $pos := $count - count($x/following::*:fig)
  return
  if (($pos mod 4) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig4.jpg"/>
  else if (($pos mod 3) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig3.jpg"/>
  else if (($pos mod 2) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig2.jpg"/>
  else replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig1.jpg"/>
  
)
return
copy $copy2 := $copy
modify(
for $x in $copy2//*:addr-line[*:named-content]
return replace node $x with <city>{$x/(*:named-content/*|*:named-content/text())}</city>,

for $x in $copy2//*:back/*:sec
  return if ($x/@sec-type="additional-information" and $x/preceding::*:body) then (insert node $x as last into $x/preceding::*:body, delete node $x)
  else if ($x/@sec-type="supplementary-material" and $x/preceding::*:body) then (insert node $x as last into $x/preceding::*:body, delete node $x)
  else delete node $x,
   
  for $x in  $copy2//*:underline/*:named-content[@content-type="sequence"]
  return replace node $x with $x/(text()|*),
  
  for $x in  $copy2//*:fn-group[@content-type="author-contribution"]
  return delete node $x,
  
  for $x in $copy2//*:table-wrap-foot/*:fn
  return replace node $x with <fn-group>{$x}</fn-group>,
  
  for $x in $copy2//*:styled-content
  return delete node $x,
  
  for $x in $copy2//*:p//*:list
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()]),
  
  for $x in $copy2//*:code
  let $c := $x/data()
  return 
  if (count($x/parent::*:p/child::*) = 1) then replace node $x/parent::*:p with  <preformat>{$c}</preformat>
  else  replace node $x with <monospace>{$c}</monospace>,
  
  for $x in $copy2//*:article-meta/*:contrib-group[@content-type="section"]/following-sibling::*:contrib-group
  return delete node $x,
  
  for $x in $copy2//*:app//*:sec[@sec-type="appendix"]
  return delete node $x/@sec-type,
  
  for $x in $copy2//*:article-meta/*:contrib-group/*:contrib[not(child::*:name)]
  return if ($x//*:contrib-group) then delete node $x
  else insert node <name><surname>Placeholder</surname></name> as first into $x,
  
   for $x in $copy2//(*:td|*:th)/*:p
  return replace node $x with $x/(*|text())
  )
return 
copy $copy3 := $copy2
modify(

  for $x in $copy3//*:contrib-group[@content-type="section"]/*//*:aff
  let $id := replace(generate-id($x),'id','aff')
  return (replace node $x with <xref ref-type="aff" rid="{$id}"/>, insert node <aff id="{$id}">{$x/*}</aff> after $x/ancestor::*:contrib-group),

  for $x in $copy3//*:contrib-group[not(@content-type="section")]/*:aff
  return (insert node $x after $x/parent::*:contrib-group, delete node $x),
  
  for $x in $copy3//*:contrib-group[@content-type="section"]/*:aff
  let $id := replace(generate-id($x),'id','aff')
  return (
    delete node $x,
    for $y in $x/preceding-sibling::*:contrib return insert node <xref ref-type="aff" rid="{$id}"/> as last into $y,
    insert node <aff id="{$id}">{$x/*}</aff> after $x/ancestor::*:contrib-group
          ),
  
  for $x in $copy3//*:self-uri
  return delete node $x,
  
  for $x in $copy3//*:custom-meta-group
  return delete node $x,
         
  for $x in $copy3//*:ref//*:ext-link
  return replace node $x with <uri>{$x/text()}</uri>,
  
  for $x in  $copy3//*:xref[@ref-type="video"]
  return delete node $x,
  
  for $x in  $copy3//*:sec[@sec-type="data-availability"]
  return delete node $x,
  
  for $x in  $copy3//*:sec[@sec-type="datasets"]
  return delete node $x,
  
  for $x in $copy3//*:app
  return (delete node $x, insert node <sec sec-type="appendix">{$x/*[not(local-name() = 'object-id')]}</sec> as last into $x/preceding::*:body),
  
  for $x in $copy3//*:p//*:list
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()])

)
return 
copy $copy4 := $copy3
modify(
  
  for $x in  $copy4//*:article-meta/*:contrib-group[@content-type="section"]
  return
    (delete node $x,
     insert node $x after $x/parent::*:article-meta/*:contrib-group[not(@*)][1]),
  
  for $x in  $copy4//*:p//*:fig
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()]),
  
  for $x in  $copy4//*:p//*:fig-group
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()]),
  
  for $x in  $copy4//*:p//*:table-wrap
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()]),
  
   for $x in  $copy4//*:list-item//*:table-wrap
  return (delete node $x, insert node $x after $x/ancestor::*:list[position() = last()]),
  
  for $x in  $copy4//*:p/*:related-object
  return delete node $x,
  
  for $x in  $copy4//*:app-group
  return delete node $x,
   
  for $x in  $copy4//*:element-citation[@publication-type="web"]
  return replace value of node $x/@publication-type with 'webpage',
  
  for $x in  $copy4//*:element-citation[@publication-type="preprint"]
  return replace value of node $x/@publication-type with 'journal',
  
  for $x in  $copy4//*:element-citation[@publication-type="other"]
  return replace value of node $x/@publication-type with 'software',
  
  for $x in  $copy4//*:element-citation[@publication-type="journal" or @publication-type="book"]
  return if (count($x/*:volume) > 1) then (for $y in $x/*:volume return delete node $y,
                                             insert node $x/*:volume[1] after $x/*:source)
         else ()
)
return 
copy $copy5 := $copy4
modify(
  
  for $x in $copy5//*:ext-link
  let $p := $x/parent::*
  let $p-name := $p/local-name()
  let $form := ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')
  let $new-x := <ext-link ext-link-type="uri" xlink:href="{$x/@xlink:href}">{$x/(*|text())}</ext-link>
  return 
  if ($p-name = $form) then (delete node $p, insert node $new-x after $p)
  else if ($x/@ext-link-type) then
    if ($x/@ext-link-type='uri') then ()
    else replace value of node $x/@ext-link-type with 'uri'
  else insert node attribute ext-link {'uri'} into $x,
  
  for $x in $copy5//(*:table[not(@id)]|*:td[not(@id)]|*:tr[not(@id)]|*:th[not(@id)])
  let $id := generate-id($x)
  return insert node attribute id {$id} into $x,
  
  for $x in $copy5//*[*:inline-formula]
  let $n := $x/local-name()
  return 
  if ($n = ('sup','sub','italic','bold','underline')) then replace node $x with $x/(*|text())
  else (),
  
  for $x in $copy5//*:aff/*:institution
  return if ($x/@content-type) then replace value of node $x/@content-type with 'orgdiv1'
         else insert node attribute content-type {'orgname'} into $x,
         
  for $x in $copy5//*:p//*:list
  return (delete node $x, insert node $x after $x/ancestor::*:p[position() = last()])
  
)
return 
copy $copy6 := $copy5
modify(
  
  for $m in $copy6//mml:math
  return 
  if ($m/parent::*:inline-formula) then replace node $m with <tex-math>e=mc^2</tex-math>
  else if ($m/parent::*:disp-formula) then replace node $m with <tex-math>e=mc^2</tex-math>
  else delete node $m,
  
  for $x in $copy6//*:ext-link[child::*]
  return replace node $x with <ext-link ext-link-type='uri' xlink:href="{$x/@xlink:href}">{$x/data()}</ext-link>,
  
  for $x in $copy6//*:xref
  let $form := ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')
  return if ($x/ancestor::*[local-name() = $form]) then
              (insert node $x after $x/ancestor::*[local-name() = $form][position() = last()],
                delete node $x)
         else if ($x/*[local-name() = $form]) then
               replace node $x with <xref ref-type="{$x/@ref-type}" rid="{$x/@rid}">{$x/data()}</xref>
         else (),
         
  for $x in $copy6//*:collab/*
  let $bad-children := ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')
  return if ($x/local-name() = $bad-children) then
              replace node $x with $x/(*|text())
         else ()
  
)
return 
copy $copy7 := $copy6
modify(
  
  for $x in $copy7//*:p//*:table-wrap
  return (insert node $x after $x/ancestor::*:p,
          delete node $x/ancestor::*:p),
          
  for $x in $copy7//*:fig/*:graphic[preceding-sibling::*:graphic]
  return delete node $x
  
)
return 
copy $copy8 := $copy7
modify(
  
  for $x in  $copy8//*:table-wrap-foot[count(fn-group)>1]
  return (for $c in $x/descendant::*:fn-group
           let $count :=  count($c/ancestor::*:table-wrap-foot//*:fn-group)
          let $pos := $count - count($c/following-sibling::*:fn-group)
        return if ($pos > 1) then (for $y in $c/*:fn return insert node $y as last into $y/ancestor::table-wrap-foot/descendant::*:fn-group[1], delete node $c)
      else ()),
      
  for $x in $copy8//*:inline-formula
  let $form := ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')
  return 
    if ($x//ancestor::*[local-name() = $form]) then 
      (insert node $x before $x//ancestor::*[local-name() = $form][position() = last()],
      delete node $x)
  else (),
  
  for $y in $copy8//*:conf-name/*:italic
  return replace node $y with $y/(*|text()),
  
  for $y in $copy8//*:element-citation/*:year[preceding-sibling::*:year]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:fpage[preceding-sibling::*:fpage]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:lpage[preceding-sibling::*:lpage]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:elocation-id[preceding-sibling::*:elocation-id]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:conf-name[preceding-sibling::*:conf-name]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:uri[preceding-sibling::*:uri]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:article-title[preceding-sibling::*:article-title]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:source[preceding-sibling::*:source]
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:conf-date
  return delete node $y,
  
  for $y in $copy8//*:element-citation/*:version
  return 
  if ($y/*:uri) then delete node $y
  else if ($y/preceding-sibling::*:uri) then delete node $y
  else (),
    
  for $y in $copy8//*:element-citation//*:surname/*:uri
  return replace node $y with $y/*,
  
  for $y in $copy8//*:volume//(*:sup|*:bold|*:italic)
  return replace node $y with $x/text(),
  
  for $x in $copy8//*:uri/*:uri
  return 
    if ($x/ancestor::*:ref) then
      if ($x/parent::*:uri/@xlink:href) then replace node $x with $x/text()
      else if ($x/@xlink:href) then replace node $x/parent::*:uri with $x
      else delete node $x/parent::*:uri
    else if ($x/parent::*:uri/@xlink:href) then replace node $x/parent::*:uri with <ext-link ext-link-type="uri" xlink:href="{$x/parent::*:uri/@xlink:href}">{$x/text()}</ext-link>
    else if ($x/@xlink:href) then replace node $x/parent::*:uri with <ext-link ext-link-type="uri" xlink:href="{$x/@xlink:href}">{$x/text()}</ext-link>
    else delete node $x/parent::*:uri,
    
  for $x in $copy8//*:uri[ancestor::*:body]
  return replace node $x with <ext-link ext-link-type="uri" xlink:href="{$x/@xlink:href}">{$x/text()}</ext-link>,
  
  for $y in $copy8//*:aff/*:label[preceding-sibling::*:label]
  return delete node $y,
  
  for $x in $copy8//*:contrib/*:email[preceding-sibling::*:email]
  return delete node $x,
  
  for $x in $copy8//*:fig/*:p
  return 
  if ($x/parent::*:fig/*:caption) then 
          (delete node $x,
          insert node $x as last into $x/parent::*:fig/*:caption[1])
  else if ($x/parent::*:fig/*:label) then 
          (delete node $x,
          insert node <caption>{$x}</caption> after $x/parent::*:fig/*:label[1])
  else delete node $x,
  
  for $x in $copy8//*:media[@mimetype="video"]
  return delete node $x,
  
  for $x in $copy8//*:break
  return delete node $x,
  
  for $x in $copy8//*:named-content
  return 
  if (starts-with($x/@content-type,'author-callout-style')) then delete node $x
  else (),
  
  for $x in $copy8//*:fig/*:permissions[preceding-sibling::*:permissions]
  return delete node $x
  
)

return 
copy $copy9 := $copy8
modify(


  for $x in $copy9//*:boxed-text
  return replace node $x with $x/*[local-name() = ('sec','p')],
  
  for $x in $copy9//*:contrib-group/*:on-behalf-of
  return delete node $x,
  
  for $x in $copy9//*:history/*:fn
  return delete node $x,
  
  for $x in $copy9//*[local-name() = ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')]
  let $t := normalize-space($x/data())
  return if ($t = '') then delete node $x
  else (),
  
  for $x in $copy9//*:fn/*:disp-formula
  return (delete node $x,
          insert node <p><inline-formula>{$x/(text|*[local-name() != 'label'])}</inline-formula></p> as last into $x/parent::*:fn)
  
)
return $copy9 
return $y