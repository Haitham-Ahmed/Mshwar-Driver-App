class CommissionModel {
  String? driverId;
  String? totalRides;
  String? totalAdminCommission;
  String? totalDriverEarnings;
  String? commissionRate;

  CommissionModel(
      {this.driverId,
      this.totalRides,
      this.totalAdminCommission,
      this.totalDriverEarnings,
      this.commissionRate});

  CommissionModel.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'];
    totalRides = json['total_rides']?.toString();
    totalAdminCommission = json['total_admin_commission']?.toString();
    totalDriverEarnings = json['total_driver_earnings']?.toString();
    commissionRate = json['commission_rate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driver_id'] = driverId;
    data['total_rides'] = totalRides;
    data['total_admin_commission'] = totalAdminCommission;
    data['total_driver_earnings'] = totalDriverEarnings;
    data['commission_rate'] = commissionRate;
    return data;
  }
}
