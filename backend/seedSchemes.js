const mongoose = require("mongoose");
require("dotenv").config();

const Scheme = require("./models/Scheme");

// 🔥 STEP 1: Your dataset (keep as it is)
const schemes = [
  // your full dataset (same as now)
  {
    "scheme_name": "PM Kisan Samman Nidhi",
    "scheme_type": "Central",
    "state": "All",
    "description": "Provides ₹6000 per year to small and marginal farmers in three installments.",
    "benefits": [
      "Direct income support",
      "Helps in farming expenses",
      "Improves farmer livelihood"
    ],
    "application_link": "https://pmkisan.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "Pradhan Mantri Fasal Bima Yojana",
    "scheme_type": "Central",
    "state": "All",
    "description": "Crop insurance scheme covering losses due to natural disasters.",
    "benefits": [
      "Low premium insurance",
      "Covers crop loss",
      "Financial protection"
    ],
    "application_link": "https://pmfby.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Wheat", "Cotton", "Maize", "Pulses"]
  },
  {
    "scheme_name": "Soil Health Card Scheme",
    "scheme_type": "Central",
    "state": "All",
    "description": "Provides soil health reports and fertilizer recommendations.",
    "benefits": [
      "Improves soil fertility",
      "Optimizes fertilizer usage",
      "Boosts yield"
    ],
    "application_link": "https://soilhealth.dac.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "Kisan Credit Card",
    "scheme_type": "Central",
    "state": "All",
    "description": "Provides short-term credit for agricultural needs.",
    "benefits": [
      "Easy loan access",
      "Low interest rates",
      "Flexible repayment"
    ],
    "application_link": "https://www.myscheme.gov.in/schemes/kcc",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "National Mission on Oilseeds and Oil Palm",
    "scheme_type": "Central",
    "state": "All",
    "description": "Promotes production of oilseeds and oil palm cultivation.",
    "benefits": [
      "Subsidy for seeds",
      "Training support",
      "Improves oilseed productivity"
    ],
    "application_link": "https://nmoop.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Oilseeds", "Palm"]
  },
  {
    "scheme_name": "Paramparagat Krishi Vikas Yojana",
    "scheme_type": "Central",
    "state": "All",
    "description": "Promotes organic farming and sustainable agriculture.",
    "benefits": [
      "Financial support for organic farming",
      "Improves soil health",
      "Better market prices"
    ],
    "application_link": "https://pgsindia-ncof.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Organic", "Vegetables", "Fruits"]
  },
  {
    "scheme_name": "Rashtriya Krishi Vikas Yojana",
    "scheme_type": "Central",
    "state": "All",
    "description": "Supports agricultural infrastructure and productivity improvement.",
    "benefits": [
      "Infrastructure development",
      "Farmer support programs",
      "Boosts production"
    ],
    "application_link": "https://rkvy.nic.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "National Food Security Mission",
    "scheme_type": "Central",
    "state": "All",
    "description": "Increases production of rice, wheat, and pulses.",
    "benefits": [
      "Subsidy on seeds",
      "Improved yield",
      "Farmer training"
    ],
    "application_link": "https://nfsm.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Rice", "Wheat", "Pulses"]
  },

  {
    "scheme_name": "Rythu Bandhu Scheme",
    "scheme_type": "State",
    "state": "Telangana",
    "description": "Provides financial assistance for crop investment.",
    "benefits": [
      "Direct financial support",
      "Covers input costs",
      "Encourages cultivation"
    ],
    "application_link": "https://rythubandhu.telangana.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Cotton", "Maize"]
  },
  {
    "scheme_name": "Rythu Bima Scheme",
    "scheme_type": "State",
    "state": "Telangana",
    "description": "Life insurance scheme for farmers.",
    "benefits": [
      "Financial security",
      "Insurance coverage",
      "Family support"
    ],
    "application_link": "https://rythubima.telangana.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "YSR Rythu Bharosa",
    "scheme_type": "State",
    "state": "Andhra Pradesh",
    "description": "Provides financial support to farmers including tenant farmers.",
    "benefits": [
      "Income support",
      "Helps in farming costs",
      "Supports tenant farmers"
    ],
    "application_link": "https://ysrrythubharosa.ap.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Groundnut", "Sugarcane"]
  },
  {
    "scheme_name": "YSR Free Crop Insurance",
    "scheme_type": "State",
    "state": "Andhra Pradesh",
    "description": "Provides free crop insurance to farmers.",
    "benefits": [
      "No premium insurance",
      "Crop loss protection",
      "Financial stability"
    ],
    "application_link": "https://apagrisnet.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Cotton", "Pulses"]
  },
  {
    "scheme_name": "Krishi Bhagya Scheme",
    "scheme_type": "State",
    "state": "Karnataka",
    "description": "Supports irrigation and water conservation for farmers.",
    "benefits": [
      "Water storage support",
      "Irrigation improvement",
      "Increases productivity"
    ],
    "application_link": "https://raitamitra.karnataka.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Millets", "Pulses", "Groundnut"]
  },
  {
    "scheme_name": "Kalia Scheme",
    "scheme_type": "State",
    "state": "Odisha",
    "description": "Provides financial assistance to small and marginal farmers.",
    "benefits": [
      "Income support",
      "Support for landless farmers",
      "Livelihood improvement"
    ],
    "application_link": "https://kalia.odisha.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Rice", "Vegetables"]
  },
  {
    "scheme_name": "National Horticulture Mission",
    "scheme_type": "Central",
    "state": "All",
    "description": "Promotes horticulture crops like fruits and vegetables.",
    "benefits": ["Subsidy on planting", "Infrastructure support"],
    "application_link": "https://nhm.nic.in",
    "last_date": "Ongoing",
    "cropTypes": ["Fruits", "Vegetables"]
  },
  {
    "scheme_name": "Micro Irrigation Fund",
    "scheme_type": "Central",
    "state": "All",
    "description": "Promotes drip and sprinkler irrigation.",
    "benefits": ["Water saving", "Subsidy for irrigation systems"],
    "application_link": "https://pmksy.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "National Bamboo Mission",
    "scheme_type": "Central",
    "state": "All",
    "description": "Supports bamboo cultivation.",
    "benefits": ["Subsidy", "Market linkage"],
    "application_link": "https://nbm.nic.in",
    "last_date": "Ongoing",
    "cropTypes": ["Bamboo"]
  },

  {
    "scheme_name": "Annadata Sukhibhava",
    "scheme_type": "State",
    "state": "Andhra Pradesh",
    "description": "Financial support to farmers.",
    "benefits": ["Direct benefit transfer"],
    "application_link": "https://apagrisnet.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Pulses"]
  },
  {
    "scheme_name": "AP Farm Mechanization Scheme",
    "scheme_type": "State",
    "state": "Andhra Pradesh",
    "description": "Subsidy for farm machinery.",
    "benefits": ["Reduced labor cost", "Increased efficiency"],
    "application_link": "https://apagrisnet.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },

  {
    "scheme_name": "Mission Kakatiya",
    "scheme_type": "State",
    "state": "Telangana",
    "description": "Restoration of irrigation tanks.",
    "benefits": ["Improves irrigation", "Water conservation"],
    "application_link": "https://missionkakatiya.cgg.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Rice", "Cotton"]
  },

  {
    "scheme_name": "Raitha Siri Scheme",
    "scheme_type": "State",
    "state": "Karnataka",
    "description": "Encourages organic farming.",
    "benefits": ["Financial incentives", "Soil improvement"],
    "application_link": "https://raitamitra.karnataka.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Organic"]
  },
  {
    "scheme_name": "Bhoochetana Scheme",
    "scheme_type": "State",
    "state": "Karnataka",
    "description": "Improves soil productivity.",
    "benefits": ["Better yields", "Scientific farming"],
    "application_link": "https://raitamitra.karnataka.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Millets", "Pulses"]
  },

  {
    "scheme_name": "Uzhavar Sandhai Scheme",
    "scheme_type": "State",
    "state": "Tamil Nadu",
    "description": "Direct farmer markets.",
    "benefits": ["Better price for farmers"],
    "application_link": "https://tn.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Vegetables", "Fruits"]
  },

  {
    "scheme_name": "Chief Minister Solar Pump Scheme",
    "scheme_type": "State",
    "state": "Maharashtra",
    "description": "Solar pumps for irrigation.",
    "benefits": ["Energy savings", "Subsidy"],
    "application_link": "https://mahadiscom.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },
  {
    "scheme_name": "Magel Tyala Shettale",
    "scheme_type": "State",
    "state": "Maharashtra",
    "description": "Farm pond scheme.",
    "benefits": ["Water conservation"],
    "application_link": "https://maharashtra.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },

  {
    "scheme_name": "Punjab Crop Diversification Program",
    "scheme_type": "State",
    "state": "Punjab",
    "description": "Encourages shift from paddy to other crops.",
    "benefits": ["Subsidy", "Sustainable farming"],
    "application_link": "https://agripb.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Maize", "Pulses"]
  },

  {
    "scheme_name": "Mukhyamantri Krishi Ashirwad Yojana",
    "scheme_type": "State",
    "state": "Jharkhand",
    "description": "Financial assistance to farmers.",
    "benefits": ["Income support"],
    "application_link": "https://jharkhand.gov.in",
    "last_date": "Seasonal",
    "cropTypes": ["Rice", "Maize"]
  },

  {
    "scheme_name": "Mukhyamantri Krishak Kalyan Yojana",
    "scheme_type": "State",
    "state": "Madhya Pradesh",
    "description": "Farmer welfare scheme.",
    "benefits": ["Financial aid"],
    "application_link": "https://mp.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Wheat", "Soybean"]
  },

  {
    "scheme_name": "Uttar Pradesh Kisan Uday Yojana",
    "scheme_type": "State",
    "state": "Uttar Pradesh",
    "description": "Energy-efficient pumps for farmers.",
    "benefits": ["Electricity savings"],
    "application_link": "https://up.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },

  {
    "scheme_name": "Kisan Mitra Urja Yojana",
    "scheme_type": "State",
    "state": "Rajasthan",
    "description": "Electricity subsidy for farmers.",
    "benefits": ["Reduced electricity cost"],
    "application_link": "https://rajasthan.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["All"]
  },

  {
    "scheme_name": "West Bengal Krishak Bandhu",
    "scheme_type": "State",
    "state": "West Bengal",
    "description": "Financial assistance to farmers.",
    "benefits": ["Income support"],
    "application_link": "https://krishakbandhu.net",
    "last_date": "Seasonal",
    "cropTypes": ["Rice"]
  },

  {
    "scheme_name": "Assam Chief Minister Samagra Gramya Unnayan Yojana",
    "scheme_type": "State",
    "state": "Assam",
    "description": "Rural agriculture development.",
    "benefits": ["Infrastructure support"],
    "application_link": "https://assam.gov.in",
    "last_date": "Ongoing",
    "cropTypes": ["Rice", "Tea"]
  },
    {
      "scheme_name": "Pradhan Mantri Krishi Sinchayee Yojana",
      "scheme_type": "Central",
      "state": "All",
      "description": "Improves irrigation coverage and water use efficiency.",
      "benefits": ["Better irrigation", "Water conservation", "Higher yield"],
      "application_link": "https://pmksy.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Agriculture Infrastructure Fund",
      "scheme_type": "Central",
      "state": "All",
      "description": "Provides financial support for agricultural infrastructure.",
      "benefits": ["Loan support", "Cold storage development", "Supply chain improvement"],
      "application_link": "https://agriinfra.dac.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "e-NAM Scheme",
      "scheme_type": "Central",
      "state": "All",
      "description": "Online trading platform for agricultural produce.",
      "benefits": ["Better price discovery", "Transparent trading"],
      "application_link": "https://enam.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "National Beekeeping and Honey Mission",
      "scheme_type": "Central",
      "state": "All",
      "description": "Promotes beekeeping for additional farmer income.",
      "benefits": ["Additional income", "Pollination benefits"],
      "application_link": "https://nbhm.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Horticulture"]
    },
    {
      "scheme_name": "Mission for Integrated Development of Horticulture",
      "scheme_type": "Central",
      "state": "All",
      "description": "Promotes horticulture development.",
      "benefits": ["Subsidy", "Infrastructure"],
      "application_link": "https://midh.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Fruits", "Vegetables"]
    },
    {
      "scheme_name": "National Livestock Mission",
      "scheme_type": "Central",
      "state": "All",
      "description": "Supports livestock-based farming.",
      "benefits": ["Livestock support", "Income diversification"],
      "application_link": "https://nlm.udyamimitra.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Sub-Mission on Agricultural Mechanization",
      "scheme_type": "Central",
      "state": "All",
      "description": "Promotes mechanization in farming.",
      "benefits": ["Subsidy for machines", "Improved productivity"],
      "application_link": "https://agrimachinery.nic.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "National Mission on Sustainable Agriculture",
      "scheme_type": "Central",
      "state": "All",
      "description": "Promotes climate-resilient agriculture.",
      "benefits": ["Climate adaptation", "Sustainable farming"],
      "application_link": "https://nmsa.dac.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "PM Formalisation of Micro Food Processing Enterprises",
      "scheme_type": "Central",
      "state": "All",
      "description": "Supports food processing units.",
      "benefits": ["Financial assistance", "Market support"],
      "application_link": "https://pmfme.mofpi.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Fruits", "Vegetables"]
    },
    {
      "scheme_name": "Agri Clinics and Agri Business Centers Scheme",
      "scheme_type": "Central",
      "state": "All",
      "description": "Encourages agribusiness startups.",
      "benefits": ["Entrepreneurship support", "Loans"],
      "application_link": "https://acabcmis.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "YSR Jala Kala",
      "scheme_type": "State",
      "state": "Andhra Pradesh",
      "description": "Provides free borewell drilling for farmers.",
      "benefits": ["Water access", "Improved irrigation"],
      "application_link": "https://apagrisnet.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "AP Zero Budget Natural Farming",
      "scheme_type": "State",
      "state": "Andhra Pradesh",
      "description": "Promotes chemical-free farming.",
      "benefits": ["Reduced cost", "Organic produce"],
      "application_link": "https://apzbnf.in",
      "last_date": "Ongoing",
      "cropTypes": ["Organic"]
    },
    {
      "scheme_name": "Dr YSR Free Borewell Scheme",
      "scheme_type": "State",
      "state": "Andhra Pradesh",
      "description": "Provides borewell facilities for farmers.",
      "benefits": ["Irrigation support"],
      "application_link": "https://apagrisnet.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Telangana State Micro Irrigation Project",
      "scheme_type": "State",
      "state": "Telangana",
      "description": "Promotes drip irrigation systems.",
      "benefits": ["Water saving", "Subsidy"],
      "application_link": "https://tsmiip.cgg.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Telangana Seed Development Scheme",
      "scheme_type": "State",
      "state": "Telangana",
      "description": "Supports quality seed production.",
      "benefits": ["Better seeds", "Higher yield"],
      "application_link": "https://tsseed.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Rice", "Cotton"]
    },
    {
      "scheme_name": "Telangana Farm Mechanization Scheme",
      "scheme_type": "State",
      "state": "Telangana",
      "description": "Subsidy for farm equipment.",
      "benefits": ["Reduced labor cost"],
      "application_link": "https://tsagriculture.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Karnataka Raitha Samruddhi Yojana",
      "scheme_type": "State",
      "state": "Karnataka",
      "description": "Supports farmer income growth.",
      "benefits": ["Financial support"],
      "application_link": "https://raitamitra.karnataka.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Karnataka Krishi Yantra Dhare",
      "scheme_type": "State",
      "state": "Karnataka",
      "description": "Provides rental farm equipment.",
      "benefits": ["Affordable machinery"],
      "application_link": "https://raitamitra.karnataka.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Karnataka Organic Farming Mission",
      "scheme_type": "State",
      "state": "Karnataka",
      "description": "Promotes organic farming.",
      "benefits": ["Better soil health"],
      "application_link": "https://karnataka.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Organic"]
    },
    {
      "scheme_name": "Punjab State Farmers Commission Scheme",
      "scheme_type": "State",
      "state": "Punjab",
      "description": "Advisory and support system for farmers welfare and policy implementation.",
      "benefits": ["Policy support", "Farmer welfare guidance"],
      "application_link": "https://pbplanning.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Wheat", "Rice"]
    },
    {
      "scheme_name": "Punjab Soil Health Improvement Program",
      "scheme_type": "State",
      "state": "Punjab",
      "description": "Enhances soil fertility through scientific interventions.",
      "benefits": ["Improved soil health", "Better crop yield"],
      "application_link": "https://agripb.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Wheat", "Rice"]
    },
    {
      "scheme_name": "Punjab Agroforestry Scheme",
      "scheme_type": "State",
      "state": "Punjab",
      "description": "Promotes tree plantation alongside agriculture.",
      "benefits": ["Additional income", "Environmental benefits"],
      "application_link": "https://agripb.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Meri Fasal Mera Byora",
      "scheme_type": "State",
      "state": "Haryana",
      "description": "Digital platform for crop registration and farmer benefits.",
      "benefits": ["Direct benefit access", "Crop tracking"],
      "application_link": "https://fasal.haryana.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Haryana Bhavantar Bharpai Yojana",
      "scheme_type": "State",
      "state": "Haryana",
      "description": "Compensates farmers for price differences.",
      "benefits": ["Price protection", "Income stability"],
      "application_link": "https://agriharyana.gov.in",
      "last_date": "Seasonal",
      "cropTypes": ["Vegetables"]
    },
    {
      "scheme_name": "Haryana Solar Water Pumping Scheme",
      "scheme_type": "State",
      "state": "Haryana",
      "description": "Provides solar-powered irrigation pumps.",
      "benefits": ["Energy savings", "Subsidy"],
      "application_link": "https://hareda.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "UP Kisan Rin Mochan Yojana",
      "scheme_type": "State",
      "state": "Uttar Pradesh",
      "description": "Loan waiver scheme for farmers.",
      "benefits": ["Debt relief", "Financial stability"],
      "application_link": "https://upkisankarjrahat.upsdc.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "UP Agriculture Export Policy Scheme",
      "scheme_type": "State",
      "state": "Uttar Pradesh",
      "description": "Promotes export of agricultural products.",
      "benefits": ["Better market access", "Higher income"],
      "application_link": "https://up.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Fruits", "Vegetables"]
    },
    {
      "scheme_name": "UP Krishi Vikas Yojana",
      "scheme_type": "State",
      "state": "Uttar Pradesh",
      "description": "Supports agricultural development and productivity.",
      "benefits": ["Financial support", "Infrastructure development"],
      "application_link": "https://upagriculture.com",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Bihar Diesel Subsidy Scheme",
      "scheme_type": "State",
      "state": "Bihar",
      "description": "Provides subsidy on diesel for irrigation.",
      "benefits": ["Reduced irrigation cost"],
      "application_link": "https://state.bihar.gov.in",
      "last_date": "Seasonal",
      "cropTypes": ["Rice", "Wheat"]
    },
    {
      "scheme_name": "Bihar Organic Corridor Scheme",
      "scheme_type": "State",
      "state": "Bihar",
      "description": "Promotes organic farming along river corridors.",
      "benefits": ["Organic produce", "Higher prices"],
      "application_link": "https://krishi.bih.nic.in",
      "last_date": "Ongoing",
      "cropTypes": ["Organic"]
    },
    {
      "scheme_name": "Bihar Farm Mechanization Scheme",
      "scheme_type": "State",
      "state": "Bihar",
      "description": "Subsidy on farm equipment.",
      "benefits": ["Efficiency improvement"],
      "application_link": "https://krishi.bih.nic.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "West Bengal Crop Insurance Support Scheme",
      "scheme_type": "State",
      "state": "West Bengal",
      "description": "State-supported crop insurance benefits.",
      "benefits": ["Risk protection"],
      "application_link": "https://wb.gov.in",
      "last_date": "Seasonal",
      "cropTypes": ["Rice"]
    },
    {
      "scheme_name": "Bangla Shasya Bima",
      "scheme_type": "State",
      "state": "West Bengal",
      "description": "Crop insurance scheme for farmers.",
      "benefits": ["Free insurance"],
      "application_link": "https://banglashasyabima.net",
      "last_date": "Seasonal",
      "cropTypes": ["Rice"]
    },
    {
      "scheme_name": "West Bengal Agricultural Marketing Scheme",
      "scheme_type": "State",
      "state": "West Bengal",
      "description": "Improves marketing infrastructure.",
      "benefits": ["Better pricing"],
      "application_link": "https://wb.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Assam Soil Health Improvement Scheme",
      "scheme_type": "State",
      "state": "Assam",
      "description": "Improves soil fertility and productivity.",
      "benefits": ["Better yield"],
      "application_link": "https://assam.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Rice"]
    },
    {
      "scheme_name": "Assam Farm Mechanization Scheme",
      "scheme_type": "State",
      "state": "Assam",
      "description": "Supports use of modern farm equipment.",
      "benefits": ["Increased efficiency"],
      "application_link": "https://assam.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Assam Horticulture Development Scheme",
      "scheme_type": "State",
      "state": "Assam",
      "description": "Promotes horticulture farming.",
      "benefits": ["Subsidy", "Income growth"],
      "application_link": "https://assam.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["Fruits"]
    },
    {
      "scheme_name": "Gujarat Krishi Mahotsav Scheme",
      "scheme_type": "State",
      "state": "Gujarat",
      "description": "Promotes awareness and adoption of modern farming.",
      "benefits": ["Training", "Technology adoption"],
      "application_link": "https://gujaratindia.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Gujarat Soil Health Management Scheme",
      "scheme_type": "State",
      "state": "Gujarat",
      "description": "Improves soil fertility and sustainability.",
      "benefits": ["Better crop yield"],
      "application_link": "https://gujaratindia.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
    {
      "scheme_name": "Gujarat Micro Irrigation Scheme",
      "scheme_type": "State",
      "state": "Gujarat",
      "description": "Promotes efficient irrigation systems.",
      "benefits": ["Water saving"],
      "application_link": "https://gujaratindia.gov.in",
      "last_date": "Ongoing",
      "cropTypes": ["All"]
    },
      {
        "scheme_name": "Tamil Nadu Farmers Protection Scheme",
        "scheme_type": "State",
        "state": "Tamil Nadu",
        "description": "Provides financial support to farmers.",
        "benefits": ["Income support", "Farmer welfare"],
        "application_link": "https://tn.gov.in",
        "last_date": "Ongoing",
        "cropTypes": ["Rice"]
      },
      {
        "scheme_name": "TN Micro Irrigation Scheme",
        "scheme_type": "State",
        "state": "Tamil Nadu",
        "description": "Promotes drip irrigation.",
        "benefits": ["Water saving", "Higher yield"],
        "application_link": "https://tnagriculture.in",
        "last_date": "Ongoing",
        "cropTypes": ["All"]
      },
      {
        "scheme_name": "Tamil Nadu Organic Farming Scheme",
        "scheme_type": "State",
        "state": "Tamil Nadu",
        "description": "Encourages organic farming.",
        "benefits": ["Reduced cost", "Better soil health"],
        "application_link": "https://tn.gov.in",
        "last_date": "Ongoing",
        "cropTypes": ["Organic"]
      }
];

// 🔥 STEP 2: UPSERT LOGIC (NO DUPLICATES)
const seedData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB Connected");

    // 🔥 Flatten nested arrays safely
    const rows = schemes.flat();

    // 🔥 BULK UPSERT (BEST METHOD)
    const operations = rows.map((scheme) => ({
      updateOne: {
        filter: { scheme_name: scheme.scheme_name }, // unique check
        update: { $set: scheme },
        upsert: true,
      },
    }));

    await Scheme.bulkWrite(operations);

    console.log("Schemes inserted/updated successfully (no duplicates)");

    process.exit();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

seedData();