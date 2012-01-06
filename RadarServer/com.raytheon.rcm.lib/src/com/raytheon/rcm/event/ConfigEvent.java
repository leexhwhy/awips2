/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.rcm.event;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;

import com.raytheon.rcm.config.RadarConfig;


@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class ConfigEvent {
	private String radarID; // null indicates global configuration change.
	private RadarConfig oldConfig;
	private RadarConfig newConfig;
	
	public ConfigEvent() {
		
	}
	
	public ConfigEvent(String radarID, RadarConfig oldConfig,
			RadarConfig newConfig) {
		this.radarID = radarID;
		this.oldConfig = oldConfig;
		this.newConfig = newConfig;
	}

	public String getRadarID() {
		return radarID;
	}

	public void setRadarID(String radarID) {
		this.radarID = radarID;
	}

	public RadarConfig getOldConfig() {
		return oldConfig;
	}

	public void setOldConfig(RadarConfig oldConfig) {
		this.oldConfig = oldConfig;
	}

	public RadarConfig getNewConfig() {
		return newConfig;
	}

	public void setNewConfig(RadarConfig newConfig) {
		this.newConfig = newConfig;
	}
	
	public String toString() {
		if (radarID != null)
			return String.format("{Config change for radar '%s'}", radarID);
		else
			return "{Global config change}";
	}
}
