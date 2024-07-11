<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.admin.Compania"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.awt.Color" %>
<%!

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, int pageNo, int nPages, String title, String subtitle, String user, String currDate)
{
	return pdfHeader(pc, _comp, pageNo, nPages, title, subtitle, user, currDate, null, null);
}

PdfCreator pdfHeader(PdfCreator pc, Compania _comp, int pageNo, int nPages, String title, String subtitle, String user, String currDate, String xtraCompanyInfo, String xtraSubtitle)
{
	String cTable = pc.getCurrentTableName();
	Vector setHeader = new Vector();
		setHeader.addElement(".2");
		setHeader.addElement(".28");
		setHeader.addElement(".04");
		setHeader.addElement(".28");
		setHeader.addElement(".2");

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable(cTable);
		pc.setFont(12, 1);

		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

		pc.setVAlignment(2);

		pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		pc.addCols("Pg. "+pageNo+" de "+nPages,2,2,15.0f);

		/*pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		pc.addCols("Pg. "+pageNo+" de "+nPages,2,1,15.0f);*/

		pc.setFont(12, 1);
		pc.addBorderCols("",0,5,1.5f,0.0f,0.0f,0.0f,5.0f);
		 pc.addTable();
	pc.copyTable("headerTop");

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable(cTable);
		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,3);
		pc.setFont(7, 0);
		pc.addCols(""+user,2,1);
	pc.addTable();

	pc.createTable(cTable);
		pc.setFont(9, 0);
		pc.addCols("",1,1);

		//pc.addCols("Apdod. "+_comp.getApartadoPostal(),2,1);

		pc.addCols("Apdo. "+_comp.getApartadoPostal(),2,1);

		pc.addCols("",1,1);
		pc.addCols("Tels. "+_comp.getTelefono(),0,1);
		pc.setFont(7, 0);
		pc.addCols(""+currDate,2,1);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraCompanyInfo,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.addCols(" ",0,5,5.0f);
	pc.addTable();
	pc.copyTable("headerBottom");

	return pc;
}

PdfCreator pdfHeader(PdfCreator pc, Compania _comp, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	String cTable = pc.getCurrentTableName();
	Vector cWidth = new Vector();
		cWidth.addElement(".2");
		cWidth.addElement(".28");
		cWidth.addElement(".04");
		cWidth.addElement(".28");
		cWidth.addElement(".2");

	pc.setNoColumnFixWidth(cWidth);
	pc.createTable("company");
		pc.setFont(12, 1);

		pc.addImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

		pc.setVAlignment(2);

		pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.addCols("",1,1,15.0f);


		pc.addBorderCols("",0,cWidth.size(),1.5f,0.0f,0.0f,0.0f,5.0f);

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,3);
		pc.setFont(7, 0);
		pc.addCols(""+user,2,1);

		pc.setFont(9, 0);
		pc.addCols("",1,1);
		pc.addCols("Apdo. "+_comp.getApartadoPostal(),2,1);
		pc.addCols("",1,1);
		pc.addCols("Tels. "+_comp.getTelefono(),0,1);
		pc.setFont(7, 0);
		pc.addCols(""+currDate,2,1);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraCompanyInfo,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.addCols(" ",0,cWidth.size(),5.0f);
	pc.useTable(cTable);
	pc.addTableToCols("company",1,dHeaderSize);

	return pc;
}

/*Header que trae la informacion del paciente*/
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, CommonDataObject cdoPac, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	String cTable = pc.getCurrentTableName();
		//New Line
	//Pueden eliminar esta parte si cambian getPacData() de SQLMgr.
	Hashtable iTipaje = new Hashtable();
	iTipaje.put("1","A+");
	iTipaje.put("2","A-");
	iTipaje.put("3","B+");
	iTipaje.put("4","B-");
	iTipaje.put("5","O+");
	iTipaje.put("6","O-");
	iTipaje.put("7","AB+");
	iTipaje.put("8","AB-");
	iTipaje.put("9","A1+");
	///

	float cHeight = 12.0f;
	Vector cWidth = new Vector();
		cWidth.addElement(".050");
		cWidth.addElement(".05");
		cWidth.addElement(".083");
		cWidth.addElement(".189");
		cWidth.addElement(".074");
		cWidth.addElement(".15");
		cWidth.addElement(".068");
		cWidth.addElement(".146");
		cWidth.addElement(".057");
		cWidth.addElement(".133");

	Vector vecImage = new Vector();
		vecImage.addElement("0.01");
		vecImage.addElement("0.98");
		vecImage.addElement("0.01");

	pc.setNoColumnFixWidth(vecImage);
		pc.createTable("image", false);
		pc.addCols("",0,1);
		pc.addImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
		pc.addCols("",0,1);
		pc.addBorderCols("",0,vecImage.size(),1.5f,0.0f,0.0f,0.0f);

	pc.setNoColumnFixWidth(cWidth);
	pc.createTable("header", false);

		pc.addTableToCols("image",1,cWidth.size());

		pc.setFont(7, 0);
		pc.addCols(user,2,cWidth.size());
		pc.addCols(currDate,2,cWidth.size());

		pc.setVAlignment(0);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols(""+xtraCompanyInfo,1,cWidth.size());
		}

		if (title != null && !title.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,cWidth.size());
		}

		if (subtitle != null && !subtitle.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,cWidth.size());
		}

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals("")&& !xtraSubtitle.trim().equals("ANALISIS"))
		{
			pc.setFont(9, 0);
			pc.addCols(""+xtraSubtitle,1,cWidth.size());
		}

		pc.addBorderCols("",0,cWidth.size(),0.5f,0.0f,0.0f,0.0f,cHeight);

				int labelFont = 6;
				int dataFont = 6;

				if (cdoPac.getColValue("is_landscape") != null && cdoPac.getColValue("is_landscape","false").equalsIgnoreCase("true")) {
						labelFont = 7;
						dataFont = 8;
				}

		pc.setFont(labelFont, 0);
		pc.addBorderCols("PID:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("pac_id"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Nombre:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);

				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("nombre_paciente"),0,8,0.0f,0.0f,0.0f,0.0f,cHeight);

		pc.setFont(labelFont, 0);
		pc.addBorderCols("No. Adm.:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("admision"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);

		pc.addBorderCols("Ced/Pass:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				 pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("identificacion"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Fecha Nac.:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				 pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("f_nac"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Edad:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("edad") + " Sexo: " + cdoPac.getColValue("sexo"),0,3,0.0f,0.0f,0.0f,0.0f,cHeight);

				pc.setFont(labelFont, 0);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Fecha Ingreso:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("fecha_ingreso"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Cama:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("cama"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Area/Centro Adm:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("centro_servicio_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Categoría:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("categoria_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);

		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue(""),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Méd. Tratante:",0,1,0.0f,0.0f,0.0f,0.0f);
				pc.setFont(dataFont, 0);
		pc.addBorderCols("["+cdoPac.getColValue("medico"," ")+"] "+cdoPac.getColValue("nombre_medico"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Méd. Cabecera:",0,1,0.0f,0.0f,0.0f,0.0f);
				pc.setFont(dataFont, 0);
		pc.addBorderCols("["+cdoPac.getColValue("cod_medico_c"," ")+"] "+cdoPac.getColValue("nombre_medico_cabecera"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Religión:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("religion_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(labelFont, 0);
		pc.addBorderCols("Tipaje:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.setFont(dataFont, 0);
		//pc.addBorderCols(cdoPac.getColValue("tipo_sangre"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		//New Line
				pc.setFont(dataFont, 0);
		pc.addBorderCols((iTipaje.get(cdoPac.getColValue("tipo_sangre"))!=null?""+iTipaje.get(cdoPac.getColValue("tipo_sangre")):""),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);

		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.setFont(labelFont, 0);
		pc.addBorderCols("Area de Atención:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("cds_atencion_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.setFont(labelFont, 0);
		pc.addBorderCols("Peso:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.setFont(dataFont, 0);
		pc.addBorderCols(cdoPac.getColValue("weight_height")!=null?(cdoPac.getColValue("weight_height")).replaceAll("\\|",""):"",0,5,0.0f,0.0f,0.0f,0.0f,cHeight);

		if (cdoPac.getColValue("mostrar_alergia") != null && cdoPac.getColValue("mostrar_alergia").equalsIgnoreCase("S")) {

			pc.setFont(labelFont, 0,Color.RED);
			pc.addBorderCols(((cdoPac.getColValue("alergias") != null && !cdoPac.getColValue("alergias").trim().equals(""))?"Alergias: ":""),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.setFont(dataFont, 0,Color.RED);
			pc.addBorderCols(cdoPac.getColValue("alergias"),0,9,0.0f,0.0f,0.0f,0.0f,cHeight);
 
		}
				if (xtraSubtitle != null && !xtraSubtitle.trim().equals("")&& xtraSubtitle.trim().equals("ANALISIS")){
		if (cdoPac.getColValue("verAseg"," ").equalsIgnoreCase("S"))
		{
						pc.setFont(labelFont, 0);
			pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.setFont(dataFont, 0);
			pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.setFont(labelFont, 0);
			pc.addBorderCols("Aseguradora:",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);

			pc.setFont(dataFont, 0);
			pc.addBorderCols(cdoPac.getColValue("nombreAseg"),0,8,0.0f,0.0f,0.0f,0.0f,cHeight);
				}}
		if (cdoPac.getColValue("mostrar_diag"," ").equalsIgnoreCase("S")||cdoPac.getColValue("mostrar_diag"," ").equalsIgnoreCase("Y")) {
						pc.setFont(dataFont, 0,Color.BLACK);
						pc.addBorderCols("Diagnostico:   "+cdoPac.getColValue("diagnostico"," "),0,cWidth.size(),0.0f,0.0f,0.0f,0.0f,cHeight);
				}


				pc.setFont(dataFont, 0);
				pc.setFont(dataFont, 0);


		pc.addBorderCols(" ",0,cWidth.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.useTable(cTable);
	pc.addTableToCols("header", 1, dHeaderSize);

	return pc;
}
%>
