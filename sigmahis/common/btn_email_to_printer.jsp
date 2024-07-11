 <%
 String fg = request.getParameter("fg"); //mandatory
 String cds = request.getParameter("cds");
 String btnTxt = request.getParameter("btnTxt");
 String btnName = request.getParameter("btnName");
 String disabled = request.getParameter("disabled"); //n,y
 String radioCheckObj = request.getParameter("radioCheckObj"); //
 String xtraParam = request.getParameter("xtraParam"); //
 String size = request.getParameter("size");
 String openInParent = request.getParameter("openInParent");
 String selected = request.getParameter("selected");
 if(fg.trim().equals("")) throw new Exception("[common.btn_email_to_printer] No encontramos donde va dirigigo el botón!");
 if (btnName==null)btnName="email_to_print";
 if (btnTxt==null)btnTxt="Email to print";
 if (disabled==null) disabled = "n";
 if (size==null) size="0";
 if (xtraParam==null) xtraParam="";
 if(openInParent==null) openInParent = ""; 
 if(selected==null) selected = ""; 
 if(radioCheckObj==null) radioCheckObj = ""; 
 
 if(radioCheckObj.trim().equals("") && Integer.parseInt(size) > 0 ) throw new Exception("[common.btn_email_to_printer] No encontramos los checkboxex/radiobuttons!");
 
 if (openInParent.trim().equalsIgnoreCase("y")) openInParent = "parent.";
 
 %>
 
 <input type="button" class="CellbyteBtn " value="<%=btnTxt%>" id="<%=btnName%>" name="<%=btnName%>" <%=disabled.equals("y")?"disabled=disabled":""%>>
 
 
 <script type="text/javascript">
 $(document).ready(function(){
	$("#<%=btnName%>").on("click",function(){
	   var tot = parseInt("<%=size%>",10);
	   var sel = [];
	   
	   if (tot < 1) <%=openInParent%>showPopWin('<%=request.getContextPath()%>/common/email_to_printer.jsp?fg=<%=fg+xtraParam%>',winWidth*.65,winHeight*.60,null,null,''); 
	   else{
		   for (f = 0; f<tot; f++){
			 if ($("#<%=radioCheckObj%>"+f).prop("checked")==true) {sel.push($("#<%=radioCheckObj%>"+f).val());}
		   }
		   
		   if (sel.length>0){
			   if ($(this).attr("name") == "<%=btnName%>"){
				 <%=openInParent%>showPopWin('<%=request.getContextPath()%>/common/email_to_printer.jsp?fg=<%=fg+xtraParam%>&<%=selected%>='+sel,winWidth*.65,winHeight*.60,null,null,'');
			   }
		   } 
		   else {alert("Por favor escoge al menos selecciona algo!");}
		}
		
	});
	
});
 </script>