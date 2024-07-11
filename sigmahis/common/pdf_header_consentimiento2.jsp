<%@ page import="issi.admin.UserDetail" %>
<%@ page import="issi.admin.Compania" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%!

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
String otherImageDir = ResourceBundle.getBundle("path").getString("images");

/*Header que trae la informacion del paciente*/
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, CommonDataObject cdoPac, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	float cHeight = 12.0f;
	Vector cWidth = new Vector();
		cWidth.addElement(".055");
		cWidth.addElement(".05");
		cWidth.addElement(".079");
		cWidth.addElement(".185");
		cWidth.addElement(".08");
		cWidth.addElement(".15");
		cWidth.addElement(".068");
		cWidth.addElement(".153");
		cWidth.addElement(".054");
		cWidth.addElement("0.13");
		
		if (cdoPac == null) cdoPac = new CommonDataObject();

	Vector vecImage = new Vector();
		vecImage.addElement("0.11");
		vecImage.addElement("0.78");
		vecImage.addElement("0.11");

	pc.setNoColumnFixWidth(vecImage);
		//String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth
		pc.createTable("image", false);
		//if (cdoPac.getColValue("condicionPaciente")!=null && cdoPac.getColValue("condicionPaciente").trim().equals("S"))pc.addImageCols(otherImageDir+File.separator+"caida_s.png",60.0f,0);
		//else pc.addCols("",1,1);
		
		
		if (cdoPac.getColValue("condicionPaciente") != null && cdoPac.getColValue("condicionPaciente").equals("Y")){
		   pc.addImageCols(otherImageDir+File.separator+"caida_s.png",60.0f,0);
		}else if (cdoPac.getColValue("condicionPaciente") != null && cdoPac.getColValue("condicionPaciente").equals("S")){
		  pc.addImageCols(otherImageDir+File.separator+"caida_s.png",60.0f,0);
		}else pc.addCols("",1,1);

		pc.addImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),60.0f,1);
		pc.addCols("",1,1);
		
		
		pc.addBorderCols("",0,vecImage.size(),1.5f,0.0f,0.0f,0.0f);
		

	pc.setNoColumnFixWidth(cWidth);
	pc.createTable("header", false);

		pc.addTableToCols("image",0,cWidth.size());

		pc.setFont(7, 0);
		pc.addBorderCols(user,2,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(currDate,2,cWidth.size(),0.0f,0.0f,0.0f,0.0f);

		pc.setVAlignment(0);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addBorderCols(""+xtraCompanyInfo,1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (title != null && !title.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addBorderCols(""+((title != null && !title.trim().equals(""))?title:" "),1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (subtitle != null && !subtitle.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addBorderCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addBorderCols(""+xtraSubtitle,1,cWidth.size());
		}

		pc.addBorderCols("s",0,cWidth.size(),0.5f,0.0f,0.0f,0.0f, cHeight);

		pc.setFont(6, 0);
		pc.addBorderCols("PID:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("pac_id"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Nombre:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("nombre_paciente"),0,1,0.0f,0.0f,0.0f,0.0f,  (cdoPac.getColValue("nombre_paciente").length()>27?20f:cHeight));
		pc.addBorderCols("Ced/Pass:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("identificacion"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Fecha Nac.:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("f_nac"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Edad:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("edad") + "  " + "Sexo: " + cdoPac.getColValue("sexo"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols("No. Adm.:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("admision"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Fecha Ingreso:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("fecha_ingreso"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Cama:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols((cdoPac.getColValue("cama").equals("")?"N/A":cdoPac.getColValue("cama")),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Area/Centro:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("centro_servicio_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Categoria:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("categoria_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue(""),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Méd. Tratante:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("["+cdoPac.getColValue("medico"," ")+"] "+cdoPac.getColValue("nombre_medico"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Religión:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("religion_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		//pc.addBorderCols(cdoPac.getColValue("tipo_sangre"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		//New Line
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols(" ",0,cWidth.size(),0.0f,0.5f,0.0f,0.0f, cHeight);
	pc.useTable("main");
	pc.addTableToCols("header", 1, dHeaderSize);

	return pc;
}
%>