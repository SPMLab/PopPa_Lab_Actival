function ButtonDownFcn_callback(src, event, hr, min, sec, ms) 
   [hr, min, sec, ms*10]
   delete(src.Parent)
end 
